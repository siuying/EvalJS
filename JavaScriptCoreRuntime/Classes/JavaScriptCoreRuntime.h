//
//  JavaScriptCoreRuntime.h
//  JavaScriptCoreRuntime
//
//  Created by Chong Francis on 13年1月23日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JavaScriptCore/JavaScriptCore.h"
#import "EJConvert.h"

@interface JavaScriptCoreRuntime : NSObject {
    JSGlobalContextRef context;
}

- (id)eval:(NSString *)script;

@end
