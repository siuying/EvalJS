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

@interface EvalJS : NSObject {
    JSGlobalContextRef context;
}

// eval javascript, if there are errors eval the script, set error to the error
-(id)eval:(NSString *)script error:(NSError**)error;

// eval javascript, ignore any error returned
-(id)eval:(NSString *)script;

@end
