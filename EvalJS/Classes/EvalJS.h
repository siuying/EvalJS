//
//  JavaScriptCoreRuntime.h
//  JavaScriptCoreRuntime
//
//  Created by Chong Francis on 13年1月23日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"

extern NSString *const EvalJSErrorDomain;

typedef id (^EvalJSBlock)(NSUInteger argc, NSArray* argv);

@interface EvalJS : NSObject {
    JSGlobalContextRef context;
    NSMutableDictionary* callbackBlocks;
}

@property (readonly, nonatomic) NSMutableDictionary* callbackBlocks;

// eval javascript, return the result object when success.
// if there are exception when eval the script, return nil and set error to the error
-(id) eval:(NSString *)script error:(NSError**)error;

// eval javascript, return the result object when success.
// if there are exception when eval the script, return nil.
-(id) eval:(NSString *)script;

// Load script file from resource path.
// @param filename Javascript filename in resources path, without the js extension.
// @return if there are exception when eval the script.
-(id) loadScript:(NSString *)filename;

// Load script file from resource path.
// @param filename Javascript filename in resources path, without the js extension.
// @error pointer to error object
// @return if there are exception when eval the script, return nil and set error to the error.
-(id) loadScript:(NSString *)filename error:(NSError**) error;

// create a javascript function that run the supplied Objective-C Block.
// Return true when function created successfully.
// Return false when exception occurred while creating the function, error object will set to the error.
-(BOOL) createFunction:(NSString*)functionName callback:(EvalJSBlock)callback error:(NSError**) error;

// create a javascript function that run the supplied Objective-C Block.
// Return true when function created successfully.
// Return false when exception occurred while creating the function.
-(BOOL) createFunction:(NSString*)functionName callback:(EvalJSBlock)callback;

@end
