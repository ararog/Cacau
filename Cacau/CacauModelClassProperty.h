//
//  CacauModelClassProperty.h
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacauModelClassProperty : NSObject

/** The name of the declared property (not the ivar name) */
@property (copy, nonatomic) NSString* name;

/** A property class type  */
@property (assign, nonatomic) Class type;

/** Struct name if a struct */
@property (strong, nonatomic) NSString* structName;

/** If YES, the property represents a primary key column */
@property (assign, nonatomic) BOOL isPrimaryKey;

/** If YES, the property represents a autoincrement column */
@property (assign, nonatomic) BOOL isAutoIncrement;

/** If YES, the property represents a NULL column */
@property (assign, nonatomic) BOOL isNullable;

/** If YES, the property represents a foreign key column */
@property (assign, nonatomic) BOOL isForeignKey;

/** If YES, the property represents a one to one relationship */
@property (assign, nonatomic) BOOL isOneToOne;

@end
