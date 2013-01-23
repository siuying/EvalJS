# EvalJS

EvalJS lets you run JavaScript code from your iOS app. It is based on [JavaScriptCore](http://trac.webkit.org/wiki/JavaScriptCore) and [Ejecta](https://github.com/phoboslab/Ejecta), but does not contain any DOM or 
Canvas/Audio objects.

A short example:

```objective-c
    EvalJS* js = [[EvalJS alloc] init];
    [js eval:@"function test(a, b) {return a + b; }"];

    id result = [js eval:@"test(3, 2)"];
    NSLog(@"result: %@", result);
```

## License

Copyright (c) 2013 Francis Chong <francis@ignition.hk>.

Released under the MIT license. See LICENSE for details.
