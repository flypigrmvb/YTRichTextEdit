//
//  NSString+NSDate.m
//  RichTextEditDemo
//
//  Created by aron on 2017/8/2.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "NSString+NSDate.h"

@implementation NSString (NSDate)

- (NSDate*)yyyyMMddTHHmmssZDate {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSDate *date = [[self.class yyyyMMddTHHmmssZFormatter] dateFromString:self];
    return date;
}


+ (NSString*)yyyyMMddTHHmmssZDateStringFromDate:(NSDate*)date {
    return [[self.class yyyyMMddTHHmmssZFormatter] stringFromDate:date];
}


static NSDateFormatter *_yyyyMMddTHHmmssZFormatter;
+ (NSDateFormatter*)yyyyMMddTHHmmssZFormatter {
    if (!_yyyyMMddTHHmmssZFormatter) {
        _yyyyMMddTHHmmssZFormatter = [[NSDateFormatter alloc] init];
        _yyyyMMddTHHmmssZFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    }
    return _yyyyMMddTHHmmssZFormatter;
}

@end
