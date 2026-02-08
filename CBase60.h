#ifndef CBase60_h
#define CBase60_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBase60 : NSObject

+ (NSString *)encode:(NSData *)data;

+ (nullable NSData *)decode:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

#endif /* CBase60_h */
