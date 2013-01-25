//
//  JavaScriptCoreRuntime.m
//  JavaScriptCoreRuntime
//
//  Created by Chong Francis on 13年1月23日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "EvalJS.h"

SpecBegin(JavaScriptCoreRuntime)

describe(@"-eval:", ^{
    __block EvalJS* runtime;
    
    beforeEach(^{
        runtime = [[EvalJS alloc] init];
    });
    
    it(@"should eval values", ^{
        expect([runtime eval:@"1"]).to.equal(1);
        expect([runtime eval:@"\"Hello\""]).to.equal(@"Hello");
        expect([runtime eval:@"a = [1, 2, 3]"]).to.equal((@[@1, @2, @3]));
        expect([runtime eval:@"a = {a: 'hello'}"]).to.equal((@{@"a": @"hello"}));
    });
    
    it(@"should eval function and run it", ^{
        [runtime eval:@"function add(a, b) {return a + b;}"];
        expect([runtime eval:@"add(10, 2)"]).to.equal(@12);
    });
    
    describe(@"error handling", ^{
        it(@"should return nil when eval error", ^{
            id result = [runtime eval:@"function add(a, b) {return a"];
            expect(result).to.beNil();
        });

        it(@"should set error when there are error in javascript", ^{
            NSError* error = nil;
            id result = [runtime eval:@"function add(a, b) {return a" error:&error];
            expect(result).to.beNil();
            expect(error).notTo.beNil();
            expect([error domain]).to.equal(EvalJSErrorDomain);
        });
    });
});

describe(@"createFunction:callback:", ^{
    __block EvalJS* runtime;
    
    beforeEach(^{
        runtime = [[EvalJS alloc] init];
    });
    afterEach(^{
        runtime = nil;
    });

    it(@"should create a callback", ^{
        __block NSInteger testVal = 0;
        BOOL created = [runtime createFunction:@"hello" callback:^id(NSUInteger argc, NSArray *argv) {
            testVal = 1;
            return nil;
        }];
        expect(created).to.beTruthy();

        [runtime eval:@"hello();"];
        expect(testVal).to.equal(1);
    });
    
    it(@"should create a callback with parameters", ^{
        __block NSInteger testVal = 0;
        BOOL created = [runtime createFunction:@"hello" callback:^id(NSUInteger argc, NSArray *argv) {
            testVal = [[argv objectAtIndex:0] integerValue];
            return nil;
        }];
        expect(created).to.beTruthy();

        [runtime eval:@"hello(100);"];
        expect(testVal).to.equal(100);
    });
});

SpecEnd