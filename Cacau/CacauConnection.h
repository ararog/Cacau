//
//  CacauConnection.h
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacauModel.h"

@interface CacauConnection : NSObject

-(instancetype)initWithPath:(NSString *)path;
-(NSMutableArray *)query:(Class)class withSql:(NSString *)sql;
-(void) save:(CacauModel* )object;
-(void) update:(CacauModel* )object;
-(void) delete:(CacauModel* )object;
-(void) execute:(NSString *)statement;

@end
