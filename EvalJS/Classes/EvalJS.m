//
//  JavaScriptCoreRuntime.m
//  JavaScriptCoreRuntime
//
//  Created by Chong Francis on 13年1月23日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "EvalJS.h"
#import "EJConvert.h"

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

- (id)eval:(NSString *)script {
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSValueRef exception = NULL;
	JSValueRef val = JSEvaluateScript(context, scriptJS, NULL, NULL, 0, &exception);
	[self logException:exception ctx:context];
    JSStringRelease(scriptJS);
    return JSValueToJSONObject(context, val);    
}

- (void)logException:(JSValueRef)exception ctx:(JSContextRef)ctxp {
	if( !exception ) return;

	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
	JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
	
	JSObjectRef exObject = JSValueToObject( ctxp, exception, NULL );
	JSValueRef line = JSObjectGetProperty( ctxp, exObject, jsLinePropertyName, NULL );
	JSValueRef file = JSObjectGetProperty( ctxp, exObject, jsFilePropertyName, NULL );
	
	NSLog(
      @"[js][exception] %@ at line %@ in %@",
      JSValueToNSString( ctxp, exception ),
      JSValueToNSString( ctxp, line ),
      JSValueToNSString( ctxp, file )
    );
	
	JSStringRelease( jsLinePropertyName );
	JSStringRelease( jsFilePropertyName );
}

@end
