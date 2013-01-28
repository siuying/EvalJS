var console = {
    log: function(msg) {
        var argumentsArray = Array.prototype.slice.apply(arguments);  
        NSLog(argumentsArray.join(" "))
    }
};