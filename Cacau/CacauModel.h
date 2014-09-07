//
//  CacauModel.h
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EGODatabase/EGODatabase.h>
#import "CacauMapper.h"

/////////////////////////////////////////////////////////////////////////////////////////////
#if TARGET_IPHONE_SIMULATOR
#define JMLog( s, ... ) NSLog( @"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define JMLog( s, ... )
#endif
/////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Boolean function to check for null values. Handy when you need to both check
 * for nil and [NSNUll null]
 */
extern BOOL isNull(id value);

#pragma mark - Property Protocols
/**
 * Protocol for defining properties in a Cacau Model class that should not be considered 
 * as table primary key.
 *
 * @property (strong, nonatomic) NSNumber&lt;PrimaryKey&gt;* propertyName;
 *
 */
@protocol PrimaryKey
@end

/**
 * Protocol for defining properties in a Cacau Model class that should not be considered
 * as autoincrement column.
 *
 * @property (strong, nonatomic) NSNumber&lt;AutoIncrement&gt;* propertyName;
 *
 */
@protocol AutoIncrement
@end

/**
 * Protocol for defining properties in a Cacau Model class that should not be considered
 * as not null column.
 *
 * @property (strong, nonatomic) NSNumber&lt;NotNull&gt;* propertyName;
 *
 */
@protocol NotNull
@end

/**
 * Protocol for defining properties in a Cacau Model class that should not be considered
 * as foreing key column.
 *
 * @property (strong, nonatomic) Class&lt;ForeignKey&gt;* propertyName;
 *
 */
@protocol ForeignKey
@end


/**
 * Protocol for defining properties in a Cacau Model class that should not be considered
 * as one to one relationship.
 *
 * @property (strong, nonatomic) Class&lt;OneToOne&gt;* propertyName;
 *
 */
@protocol OneToOne
@end

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CacauModel protocol
/**
 * A protocol describing an abstract CacauModel class
 * CacauModel conforms to this protocol, so it can use itself abstractly
 */
@protocol AbstractCacauModelProtocol <NSObject>

@required
/**
 * All CacauModel classes should implement initWithRow:
 *
 * For most classes the default initWithRow: inherited from CacauModel itself
 * should suffice, but developers have the option ot also overwrite it if needed.
 *
 * @param dict a dictionary holding Cacau objects, to be imported in the model.
 * @param err an error or NULL
 */
-(instancetype)initWithRow:(EGODatabaseRow*)row
                andColumns:(NSMutableArray *)columns
                     error:(NSError**)err;

@end

@interface CacauModel : NSObject<AbstractCacauModelProtocol>

-(instancetype)initWithRow:(EGODatabaseRow*)row
                andColumns:(NSMutableArray *)columns
                     error:(NSError **)err;

+(CacauMapper*)columnMapper;

@end
