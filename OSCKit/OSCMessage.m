#import "OSCMessage.h"

NSInteger roundUp4(NSInteger value) {
  return ceil((float)value / 4.0) * 4;
}

@implementation OSCMessage

+ (OSCMessage *)to:(NSString *)address with:(NSArray *)arguments {
  return [[OSCMessage alloc] initWithAddress:address arguments:arguments];
}

- (id)initWithAddress:(NSString *)address arguments:(NSArray *)arguments {
  self = [self init];
  
  if(self) {
    self.address = address;
    self.arguments = arguments;
  }

  return self;
}

- (NSInteger)estimatedSize {
    NSInteger size = roundUp4([self.address lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
    
    size += roundUp4(self.arguments.count + 2); // type string with leading comma and null
    
    for (NSObject *arg in self.arguments) {
        if([arg isKindOfClass:[NSString class]]) {
            NSString *string = (NSString*)arg;
            size += roundUp4([string lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
        } else if([arg isKindOfClass:[NSNumber class]]) {
            size += 4;
        } else if([arg isKindOfClass:[NSArray class]]){
            size += 2;
            for (NSObject *arg2 in (NSArray*) arg) {
                if([arg2 isKindOfClass:[NSString class]]) {
                    NSString *string = (NSString*)arg2;
                    size += roundUp4([string lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
                } else if([arg2 isKindOfClass:[NSNumber class]]) {
                    size += 4;
                } else {
                    [[NSException exceptionWithName:@"OSCProtocolException"
                                             reason:[NSString stringWithFormat:@"argument is not an int, float, or string"]
                                           userInfo:nil] raise];
                }
            }
        } else {
            [[NSException exceptionWithName:@"OSCProtocolException"
                                     reason:[NSString stringWithFormat:@"argument is not an int, float, or string"]
                                   userInfo:nil] raise];
        }
    }
    
    return size;
}

@end
