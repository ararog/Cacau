//
//  CacauMapper.m
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import "CacauMapper.h"

@interface CacauMapper()
@property (nonatomic, strong) NSMutableDictionary *toModelMap;
@property (nonatomic, strong) NSMutableDictionary *toTableMap;
@end

@implementation CacauMapper

-(instancetype)init
{
    self = [super init];
    if (self) {
        //initialization
        self.toModelMap = [NSMutableDictionary dictionary];
        self.toTableMap  = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype)initWithTableToModelBlock:(CacauModelColumnMapBlock)toModel
                       modelToTableBlock:(CacauModelColumnMapBlock)toTable
{
    self = [self init];
    
    if (self) {
        __weak CacauMapper *myself = self;
        //the json to model convertion block
        _tableToModelColumnBlock = ^NSString*(NSString* keyName) {
            
            //try to return cached transformed key
            if (myself.toModelMap[keyName]) return myself.toModelMap[keyName];
            
            //try to convert the key, and store in the cache
            NSString* result = toModel(keyName);
            myself.toModelMap[keyName] = result;
            return result;
        };
        
        _modelToTableColumnBlock = ^NSString*(NSString* keyName) {
            
            //try to return cached transformed key
            if (myself.toTableMap[keyName]) return myself.toTableMap[keyName];
            
            //try to convert the key, and store in the cache
            NSString* result = toTable(keyName);
            myself.toTableMap[keyName] = result;
            return result;
            
        };
        
    }
    
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary*)map
{
    self = [super init];
    if (self) {
        //initialize
        
        NSMutableDictionary* userToModelMap = [NSMutableDictionary dictionaryWithDictionary: map];
        NSMutableDictionary* userToTableMap  = [NSMutableDictionary dictionaryWithObjects:map.allKeys forKeys:map.allValues];
        
        _tableToModelColumnBlock = ^NSString*(NSString* keyName) {
            NSString* result = [userToModelMap valueForKeyPath: keyName];
            return result?result:keyName;
        };
        
        _modelToTableColumnBlock = ^NSString*(NSString* keyName) {
            NSString* result = [userToTableMap valueForKeyPath: keyName];
            return result?result:keyName;
        };
    }
    
    return self;
}

-(NSString*)convertValue:(NSString*)value isImportingToModel:(BOOL)importing
{
    return !importing?_tableToModelColumnBlock(value):_modelToTableColumnBlock(value);
}

@end
