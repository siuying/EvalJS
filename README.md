# EvalJS

EvalJS lets you run JavaScript code from your iOS app. It is based on [JavaScriptCore](http://trac.webkit.org/wiki/JavaScriptCore) and [Ejecta](https://github.com/phoboslab/Ejecta), but does not contain any DOM or 
Canvas/Audio objects.

## Usage

### Evaulate Javascript

```objective-c
    EvalJS* js = [[EvalJS alloc] init];
    [js eval:@"function test(a, b) {return a + b; }"];

    id result = [js eval:@"test(3, 2)"];
    NSLog(@"result: %@", result);
```

### Create Javascript function that invoke Objective-C block

```objective-c
    EvalJS* js = [[EvalJS alloc] init];
    [js createFunction:@"hello" callback:^id(NSUInteger argc, NSArray *argv) {
        NSLog(@"hello: %@", [argv objectAtIndex:0]);
        return nil;
    }];

    id result = [js eval:@"hello(3)"];
```

The output would be: 

```
hello: 3
```

## License

Copyright (c) 2013 Francis Chong <francis@ignition.hk>.

Released under the MIT license. See LICENSE for details.
