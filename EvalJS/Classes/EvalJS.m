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

void * refToSelf;

JSValueRef EvalJSBlockCallBack(JSContextRef ctx,
                               JSObjectRef function,
                               JSObjectRef thisObject,
                               size_t argumentCount,
                               const JSValueRef arguments[],
                               JSValueRef* exception)
{
    JSStringRef jsNamePropertyName = JSStringCreateWithUTF8CString("name");
	JSValueRef jsName = JSObjectGetProperty( ctx, function, jsNamePropertyName, NULL );
    NSString* name = JSValueToNSString(ctx, jsName);

    EvalJSBlock callback = [[(EvalJS*)refToSelf callbackBlocks] objectForKey:name];
    if (callback) {
        NSMutableArray* objcArgs = [NSMutableArray array];
        for (int i=0; i < argumentCount; i++) {
            [objcArgs addObject:JSValueToJSONObject(ctx, arguments[i])];
        }

        id<NSObject> result = callback((NSUInteger) argumentCount, objcArgs);
        if ([result isKindOfClass:[NSNumber class]]) {
            NSNumber* numberVal = (NSNumber*) result;
            return JSValueMakeNumber(ctx, [numberVal doubleValue]);

        } else if ([result isKindOfClass:[NSString class]]) {
            NSString* stringVal = (NSString*) result;
            JSStringRef jsStringVal = JSStringCreateWithCFString((CFStringRef)stringVal);
            JSValueRef result = JSValueMakeString(ctx, jsStringVal);
            JSStringRelease(jsStringVal);
            return result;

        } else if ([result isKindOfClass:[NSNull class]] || result == nil) {
            return JSValueMakeNull(ctx);
        }
    }
    return JSValueMakeNull(ctx);
}

- (id)init {
	if( self = [super init] ) {
		context = JSGlobalContextCreate(NULL);
        refToSelf = self;
        callbackBlocks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(NSDictionary*) callbackBlocks {
    return callbackBlocks;
}

- (void)dealloc {
    refToSelf = nil;
	JSGlobalContextRelease(context);
    
    [callbackBlocks removeAllObjects];
    [callbackBlocks release];
    callbackBlocks = nil;

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

-(id) loadScript:(NSString *)filename {
    return [self loadScript:filename error:nil];
}

-(id) loadScript:(NSString *)filename error:(NSError**) error {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];

    NSString* fullPath = [bundle pathForResource:filename ofType:@"js"];
    NSString* script = [NSString stringWithContentsOfFile:fullPath
                                                 encoding:NSUTF8StringEncoding
                                                    error:error];
    if(!script) {
        NSLog(@"[EvalJS] script not loaded, full path: %@", fullPath);
        return nil;
    }
    
    return [self eval:script
                error:error];
}

-(BOOL) createFunction:(NSString*)functionName callback:(EvalJSBlock)callback {
    return [self createFunction:functionName callback:callback error:nil];
}

-(BOOL) createFunction:(NSString*)functionName callback:(EvalJSBlock)callback error:(NSError**) error{
    [callbackBlocks setObject:callback forKey:functionName];
	JSValueRef exception = NULL;
    JSStringRef functionNameJs = JSStringCreateWithCFString((CFStringRef)functionName);
    JSObjectRef func = JSObjectMakeFunctionWithCallback(context, functionNameJs, EvalJSBlockCallBack);
    JSObjectSetProperty(context, JSContextGetGlobalObject(context), functionNameJs, func, kJSPropertyAttributeNone, &exception);
    if (exception) {
        [self convertException:exception withContext:context toError:error];
    }
    JSStringRelease(functionNameJs);
    return exception == NULL;
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
        NSLog(@"[EvalJS] %@ in %@ of %@",
            JSValueToNSString(ctxp, exception),
            JSValueToNSString(ctxp, line),
            JSValueToNSString( ctxp, file ));
    }

	JSStringRelease( jsLinePropertyName );
	JSStringRelease( jsFilePropertyName );
}

@end
