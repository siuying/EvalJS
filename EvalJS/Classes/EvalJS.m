//
//  JavaScriptCoreRuntime.m
//  JavaScriptCoreRuntime
//
//  Created by Chong Francis on 13年1月23日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "EvalJS.h"
#import "EJConvert.h"

NSString *const EvalJSErrorDomain = @"EvalJS.ErrorDomain";

NSString * JSValueToJSONObject( JSContextRef ctx, JSValueRef val ) {
    if (!val) return nil;

    JSStringRef json = JSValueCreateJSONString(ctx, val, 0, NULL);
    NSString * jsonStr = (NSString *)JSStringCopyCFString(kCFAllocatorDefault, json);
    id result = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingAllowFragments
                                                  error:nil];
    [jsonStr autorelease];
    return result;
}

@implementation EvalJS

- (id)init {
	if( self = [super init] ) {
		context = JSGlobalContextCreate(NULL);
	}
	return self;
}

- (void)dealloc {
	JSGlobalContextRelease(context);
	[super dealloc];
}

-(id)eval:(NSString *)script {
    return [self eval:script error:nil];
}

- (id)eval:(NSString *)script error:(NSError**)error {
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSValueRef exception = NULL;
	JSValueRef val = JSEvaluateScript(context, scriptJS, NULL, NULL, 0, &exception);
    JSStringRelease(scriptJS);

    if (exception) {
        [self convertException:exception withContext:context toError:error];
    }
    return JSValueToJSONObject(context, val);
}

#pragma mark - Private

- (void)convertException:(JSValueRef)exception withContext:(JSContextRef)ctxp toError:(NSError**)error{
	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
	JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
	
	JSObjectRef exObject = JSValueToObject( ctxp, exception, NULL );
	JSValueRef line = JSObjectGetProperty( ctxp, exObject, jsLinePropertyName, NULL );
	JSValueRef file = JSObjectGetProperty( ctxp, exObject, jsFilePropertyName, NULL );

    if (error != nil) {
        NSDictionary* userInfo = @{
            @"exception": JSValueToNSString( ctxp, exception ),
            @"line": JSValueToNSString( ctxp, line ),
            @"file": JSValueToNSString( ctxp, file )
        };
        
        *error = [NSError errorWithDomain:EvalJSErrorDomain
                                     code:1
                                 userInfo:userInfo];
    } else {
        NSLog(@"[js] %@ in %@ of %@",
            JSValueToNSString(ctxp, exception),
            JSValueToNSString(ctxp, line),
            JSValueToNSString( ctxp, file ));
    }

	JSStringRelease( jsLinePropertyName );
	JSStringRelease( jsFilePropertyName );
}

@end
