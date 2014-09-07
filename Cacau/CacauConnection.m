//
//  CacauConnection.m
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <EGODatabase/EGODatabase.h>
#import "CacauConnection.h"

@interface CacauConnection ()

@property(nonatomic, strong) EGODatabase* db;

@end

@implementation CacauConnection

- (instancetype)initWithPath:(NSString *)path {
    
    self = [super init];

    if(self) {
    
        _db = [[EGODatabase alloc] initWithPath:path];
    
    }
    
    return self;
}

- (NSMutableArray *)query:(Class)class withSql:(NSString *)sql {
    
    if([class isSubclassOfClass:[CacauModel class]]) {
        
        
    }
    
    return nil;
}

- (void)execute:(NSString *)statement {
    
    [_db executeQuery:statement];
}

- (void)save:(CacauModel *)object {
    
    
}

- (void)update:(CacauModel *)object {
    
    
}

- (void)delete:(CacauModel *)object {
    
    
}

@end
