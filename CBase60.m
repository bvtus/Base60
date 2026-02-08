#import <Foundation/Foundation.h>
#import "CBase60.h"

@implementation CBase60

#pragma mark - Alphabet / Base

+ (const char *)alphabet {
    return "123456789ABCDEFGHJKLMNPQRSTUVWXYZIOabcdefghijkmnopqrstuvwxyz";
}

+ (int)base {
    return 60;
}

#pragma mark - Decode Table

+ (const int8_t *)decodeTable {
    static int8_t table[128];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        for (int i = 0; i < 128; i++) {
            table[i] = -1;
        }
        const char *a = [self alphabet];
        for (int i = 0; i < 60; i++) {
            table[(uint8_t)a[i]] = (int8_t)i;
        }
    });
    return table;
}

#pragma mark - Encode (Data → Base60, CANONICAL)

+ (NSString *)encode:(NSData *)data {
    if (data.length == 0) {
        return @"1";   // 规范：0 的唯一表示
    }

    const uint8_t *input = data.bytes;
    NSUInteger length = data.length;

    int digits[length * 2];
    memset(digits, 0, sizeof(digits));

    int digitCount = 0;

    for (NSUInteger b = 0; b < length; b++) {
        int carry = input[b];
        int i = 0;

        while (i < digitCount) {
            carry += digits[i] << 8;
            digits[i] = carry % [self base];
            carry /= [self base];
            i++;
        }

        while (carry > 0) {
            digits[digitCount++] = carry % [self base];
            carry /= [self base];
        }
    }

    // 数值为 0
    if (digitCount == 0) {
        return @"1";
    }

    NSMutableString *result = [NSMutableString stringWithCapacity:digitCount];
    const char *alpha = [self alphabet];

    for (int i = digitCount - 1; i >= 0; i--) {
        [result appendFormat:@"%c", alpha[digits[i]]];
    }

    return result;
}

#pragma mark - Decode (Base60 → Data, CANONICAL)

+ (NSData *)decode:(NSString *)string {
    if (string.length == 0) {
        return [NSData data];
    }

    NSUInteger length = string.length;

    uint8_t bytes[length];
    memset(bytes, 0, sizeof(bytes));

    int byteCount = 0;
    const int8_t *table = [self decodeTable];

    for (NSUInteger idx = 0; idx < length; idx++) {
        unichar ch = [string characterAtIndex:idx];
        if (ch >= 128) return nil;

        int value = table[ch];
        if (value < 0) return nil;

        int carry = value;
        int i = 0;

        while (i < byteCount) {
            carry += bytes[i] * [self base];
            bytes[i] = (uint8_t)(carry & 0xff);
            carry >>= 8;
            i++;
        }

        while (carry > 0) {
            bytes[byteCount++] = (uint8_t)(carry & 0xff);
            carry >>= 8;
        }
    }

    NSMutableData *result = [NSMutableData dataWithCapacity:byteCount];
    for (int i = byteCount - 1; i >= 0; i--) {
        [result appendBytes:&bytes[i] length:1];
    }

    return result;
}

@end
