//
//  CacauMapper.h
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacauMapper.h"

typedef NSString* (^CacauModelColumnMapBlock)(NSString* keyName);

@interface CacauMapper : NSObject

/** @name Name convertors */
/** Block, which takes in a JSON key and converts it to the corresponding property name */
@property (readonly, nonatomic) CacauModelColumnMapBlock tableToModelColumnBlock;

/** Block, which takes in a property name and converts it to the corresponding JSON key name */
@property (readonly, nonatomic) CacauModelColumnMapBlock modelToTableColumnBlock;

/** Combined convertor method
 * @param value the source name
 * @param importing YES invokes JSONToModelKeyBlock, NO - modelToJSONKeyBlock
 * @return JSONKeyMapper instance
 */
-(NSString*)convertValue:(NSString*)value isImportingToModel:(BOOL)importing;

/** @name Creating a key mapper */

/**
 * Creates a JSONKeyMapper instance, based on the two blocks you provide this initializer.
 * The two parameters take in a JSONModelKeyMapBlock block:
 * <pre>NSString* (^JSONModelKeyMapBlock)(NSString* keyName)</pre>
 * The block takes in a string and returns the transformed (if at all) string.
 * @param toModel transforms JSON key name to your model property name
 * @param toJSON transforms your model property name to a JSON key
 */
-(instancetype)initWithTableToModelBlock:(CacauModelColumnMapBlock)toModel
                       modelToTableBlock:(CacauModelColumnMapBlock)toTable;

/**
 * Creates a JSONKeyMapper instance, based on the mapping you provide
 * in the map parameter. Use the JSON key names as keys, your JSONModel
 * property names as values.
 * @param map map dictionary, in the format: <pre>@{@"crazy_JSON_name":@"myCamelCaseName"}</pre>
 * @return JSONKeyMapper instance
 */
-(instancetype)initWithDictionary:(NSDictionary*)map;

@end
