//
//  CacauModelError.h
//  Cacau
//
//  Created by Rogério Pereira Araújo on 07/09/14.
//  Copyright (c) 2014 Bmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(int, kJSONModelErrorTypes)
{
    kJSONModelErrorInvalidData = 1,
    kJSONModelErrorModelIsInvalid = 4,
    kJSONModelErrorNilInput = 5
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the CacauModelError instances */
extern NSString* const JSONModelErrorDomain;

/**
 * If the model JSON input misses keys that are required, check the
 * userInfo dictionary of the CacauModelError instance you get back -
 * under the kJSONModelMissingKeys key you will find a list of the
 * names of the missing keys.
 */
extern NSString* const kJSONModelMissingKeys;

/**
 * If JSON input has a different type than expected by the model, check the
 * userInfo dictionary of the CacauModelError instance you get back -
 * under the kJSONModelTypeMismatch key you will find a description
 * of the mismatched types.
 */
extern NSString* const kJSONModelTypeMismatch;

/**
 * If an error occurs in a nested model, check the userInfo dictionary of
 * the CacauModelError instance you get back - under the kJSONModelKeyPath
 * key you will find key-path at which the error occurred.
 */
extern NSString* const kJSONModelKeyPath;


@interface CacauModelError : NSError

/**
 * Creates a CacauModelError instance with code kJSONModelErrorInvalidData = 1
 */
+(id)errorInvalidDataWithMessage:(NSString*)message;

/**
 * Creates a CacauModelError instance with code kJSONModelErrorInvalidData = 1
 * @param keys a set of field names that were required, but not found in the input
 */
+(id)errorInvalidDataWithMissingKeys:(NSSet*)keys;

/**
 * Creates a CacauModelError instance with code kJSONModelErrorModelIsInvalid = 4
 */
+(id)errorModelIsInvalid;

/**
 * Creates a CacauModelError instance with code kJSONModelErrorNilInput = 5
 */
+(id)errorInputIsNil;

@end
