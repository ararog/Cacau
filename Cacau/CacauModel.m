//
//  CacauModel.m
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "CacauModel.h"
#import "CacauMapper.h"
#import "CacauModelError.h"
#import "CacauModelClassProperty.h"

#pragma mark - associated objects names
static const char * kMapperObjectKey;
static const char * kClassPropertiesKey;
static const char * kClassRequiredPropertyNamesKey;
static const char * kIndexPropertyNameKey;

static Class CacauModelClass = NULL;

extern BOOL isNull(id value)
{
    if (!value) return YES;
    if ([value isKindOfClass:[NSNull class]]) return YES;
    
    return NO;
}

@implementation CacauModel

+(void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // initialize all class static objects,
        // which are common for ALL JSONModel subclasses
        
        @autoreleasepool {
            
            // This is quite strange, but I found the test isSubclassOfClass: (line ~291) to fail if using [JSONModel class].
            // somewhat related: https://stackoverflow.com/questions/6524165/nsclassfromstring-vs-classnamednsstring
            // //; seems to break the unit tests
            
            // Using NSClassFromString instead of [JSONModel class], as this was breaking unit tests, see below
            //http://stackoverflow.com/questions/21394919/xcode-5-unit-test-seeing-wrong-class
            CacauModelClass = NSClassFromString(NSStringFromClass(self));
        }
    });
}

-(void)__setup__
{
    //if first instance of this model, generate the property list
    if (!objc_getAssociatedObject(self.class, &kClassPropertiesKey)) {
        [self __inspectProperties];
    }
    
    //if there's a custom key mapper, store it in the associated object
    id mapper = [[self class] columnMapper];
    if ( mapper && !objc_getAssociatedObject(self.class, &kMapperObjectKey) ) {
        objc_setAssociatedObject(
                                 self.class,
                                 &kMapperObjectKey,
                                 mapper,
                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                 );
    }
}

-(id)init
{
    self = [super init];
    if (self) {
        //do initial class setup
        [self __setup__];
    }
    return self;
}

-(id)initWithRow:(EGODatabaseRow*)row
      andColumns:(NSMutableArray *)columns
           error:(NSError**)err
{
    //check for nil input
    if (!row) {
        if (err) *err = [CacauModelError errorInputIsNil];
        return nil;
    }
    
    //invalid input, just create empty instance
    if (![row isKindOfClass:[EGODatabaseRow class]]) {
        if (err) *err = [CacauModelError errorInvalidDataWithMessage:@"Attempt to initialize CacauModel object using initWithDictionary:error: but the dictionary parameter was not an 'NSDictionary'."];
        return nil;
    }
    
    //create a class instance
    self = [self init];
    if (!self) {
        
        //super init didn't succeed
        if (err) *err = [CacauModelError errorModelIsInvalid];
        return nil;
    }
    
    //check incoming data structure
    if (![self __doesColumns:columns matchModelWithColumnMapper:self.__columnMapper error:err]) {
        return nil;
    }
    
    //import the data from a dictionary
    if (![self __importRow:row withColumnMapper:self.__columnMapper error:err]) {
        return nil;
    }
    
    //model is valid! yay!
    return self;
}

-(CacauMapper*)__columnMapper
{
    //get the model key mapper
    return objc_getAssociatedObject(self.class, &kMapperObjectKey);
}

-(BOOL)__doesColumns:(NSMutableArray*)columns matchModelWithColumnMapper:(CacauMapper*)columnMapper error:(NSError**)err
{
    //check if all required properties are present
    NSMutableSet* requiredProperties = [self __requiredPropertyNames];
    NSSet* incomingKeys = [NSSet setWithArray: columns];
    
    //transform the key names, if neccessary
    if (columnMapper) {
        
        NSMutableSet* transformedIncomingKeys = [NSMutableSet setWithCapacity: requiredProperties.count];
        NSString* transformedName = nil;
        
        //loop over the required properties list
        for (CacauModelClassProperty* property in [self __properties__]) {
            
            transformedName = columnMapper ? [self __mapString:property.name withColumnMapper:columnMapper importing:YES] : property.name;
            
            //chek if exists and if so, add to incoming keys
            if ([columns containsObject:transformedName]) {
                [transformedIncomingKeys addObject: property.name];
            }
        }
        
        //overwrite the raw incoming list with the mapped key names
        incomingKeys = transformedIncomingKeys;
    }
    
    //check for missing input keys
    if (![requiredProperties isSubsetOfSet:incomingKeys]) {
        
        //get a list of the missing properties
        [requiredProperties minusSet:incomingKeys];
        
        //not all required properties are in - invalid input
        JMLog(@"Incoming data was invalid [%@ initWithDictionary:]. Keys missing: %@", self.class, requiredProperties);
        
        if (err) *err = [CacauModelError errorInvalidDataWithMissingKeys:requiredProperties];
        return NO;
    }
    
    //not needed anymore
    incomingKeys= nil;
    requiredProperties= nil;
    
    return YES;
}

-(NSString*)__mapString:(NSString*)string withColumnMapper:(CacauMapper*)columnMapper importing:(BOOL)importing
{
    if (columnMapper) {
        //custom mapper
        NSString* mappedName = [columnMapper convertValue:string isImportingToModel:importing];
        string = mappedName;
    }
    
    return string;
}

-(BOOL)__importRow:(EGODatabaseRow*)row withColumnMapper:(CacauMapper*)columnMapper error:(NSError**)err
{
    //loop over the incoming keys and set self's properties
    for (CacauModelClassProperty* property in [self __properties__]) {
        
        NSString* columnName = [self __mapString:property.name
                                withColumnMapper:columnMapper
                                       importing:NO];
        
        id value;
        if (property.type == [NSString class]) {
            
            value = [row stringForColumn:columnName];
        }
        else if (property.type == [NSDate class]) {
            
            value = [row dateForColumn:columnName];
        }
        
        [self setValue:value forKey:property.name];
    }
    
    return YES;
}

#pragma mark - property inspection methods

-(BOOL)__isCacauModelSubClass:(Class)class
{
    // http://stackoverflow.com/questions/19883472/objc-nsobject-issubclassofclass-gives-incorrect-failure
#ifdef UNIT_TESTING
    return [@"CacauModel" isEqualToString: NSStringFromClass([class superclass])];
#else
    return [class isSubclassOfClass:CacauModelClass];
#endif
}

//returns a set of the required keys for the model
-(NSMutableSet*)__requiredPropertyNames
{
    //fetch the associated property names
    NSMutableSet* classRequiredPropertyNames = objc_getAssociatedObject(self.class, &kClassRequiredPropertyNamesKey);
    
    if (!classRequiredPropertyNames) {
        classRequiredPropertyNames = [NSMutableSet set];
        [[self __properties__] enumerateObjectsUsingBlock:^(CacauModelClassProperty* p, NSUInteger idx, BOOL *stop) {
            [classRequiredPropertyNames addObject:p.name];
        }];
        
        //persist the list
        objc_setAssociatedObject(
                                 self.class,
                                 &kClassRequiredPropertyNamesKey,
                                 classRequiredPropertyNames,
                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                 );
    }
    return classRequiredPropertyNames;
}

//returns a list of the model's properties
-(NSArray*)__properties__
{
    //fetch the associated object
    NSDictionary* classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    if (classProperties) return [classProperties allValues];
    
    //if here, the class needs to inspect itself
    [self __setup__];
    
    //return the property list
    classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    return [classProperties allValues];
}

//inspects the class, get's a list of the class properties
-(void)__inspectProperties
{
    //JMLog(@"Inspect class: %@", [self class]);
    
    NSMutableDictionary* propertyIndex = [NSMutableDictionary dictionary];
    
    //temp variables for the loops
    Class class = [self class];
    NSScanner* scanner = nil;
    NSString* propertyType = nil;
    
    // inspect inherited properties up to the JSONModel class
    while (class != [CacauModel class]) {
        //JMLog(@"inspecting: %@", NSStringFromClass(class));
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        //loop over the class properties
        for (unsigned int i = 0; i < propertyCount; i++) {
            
            CacauModelClassProperty* p = [[CacauModelClassProperty alloc] init];
            
            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = @(propertyName);
            
            //JMLog(@"property: %@", p.name);
            
            //get property attributes
            const char *attrs = property_getAttributes(property);
            NSString* propertyAttributes = @(attrs);
            NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
            
            //ignore read-only properties
            if ([attributeItems containsObject:@"R"]) {
                continue; //to next property
            }
            
            //check for 64b BOOLs
            if ([propertyAttributes hasPrefix:@"Tc,"]) {
                //mask BOOLs as structs so they can have custom convertors
                p.structName = @"BOOL";
            }
            
            scanner = [NSScanner scannerWithString: propertyAttributes];
            
            //JMLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //JMLog(@"type: %@", propertyClassName);
                p.type = NSClassFromString(propertyType);
                
                //read through the property protocols
                while ([scanner scanString:@"<" intoString:NULL]) {
                    
                    NSString* protocolNames = nil;
                    
                    [scanner scanUpToString:@">" intoString: &protocolNames];
                    
                    NSArray* names = [protocolNames componentsSeparatedByString:@","];
                    
                    for (NSString* protocolName in names) {
                        
                        if ([protocolName isEqualToString:@"PrimaryKey"]) {
                            p.isPrimaryKey = YES;
                        } else if([protocolName isEqualToString:@"AutoIncrement"]) {
                            p.isAutoIncrement = YES;
                        } else if([protocolName isEqualToString:@"NotNull"]) {
                            p.isNullable = NO;
                        } else if([protocolName isEqualToString:@"ForeignKey"]) {
                            p.isForeignKey = NO;
                        } else if([protocolName isEqualToString:@"OneToOne"]) {
                            p.isOneToOne = NO;
                        }
                    }
                    
                    [scanner scanString:@">" intoString:NULL];
                }
            }
            //check if the property is a structure
            else if ([scanner scanString:@"{" intoString: &propertyType]) {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                    intoString:&propertyType];
                
                p.structName = propertyType;
                
            }
            
            //add the property object to the temp index
            if (p) {
                [propertyIndex setValue:p forKey:p.name];
            }
        }
        
        free(properties);
        
        //ascend to the super of the class
        //(will do that until it reaches the root class - JSONModel)
        class = [class superclass];
    }
    
    //finally store the property index in the static property index
    objc_setAssociatedObject(
                             self.class,
                             &kClassPropertiesKey,
                             [propertyIndex copy],
                             OBJC_ASSOCIATION_RETAIN // This is atomic
                             );
}

#pragma mark - key mapping
+(CacauMapper*)columnMapper
{
    return nil;
}

@end
