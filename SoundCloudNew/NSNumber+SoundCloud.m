//
//  NSNumber+SoundCloud.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/25/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "NSNumber+SoundCloud.h"

@implementation NSNumber(SoundCloud)

- (NSString *)stringFormatValue;
{
    NSString *numberString = [[NSString alloc]init];
    
    int formatNumber = [self intValue];
    
    if (formatNumber < 0) {
        numberString = @"0";
    } else if (formatNumber < 1000) {
        numberString = [NSString stringWithFormat:@"%d", formatNumber];
    } else if (formatNumber < 1000000) {
        numberString = [NSString stringWithFormat:@"%dK", formatNumber/1000];
    } else if (formatNumber < 1000000000) {
        numberString = [NSString stringWithFormat:@"%dM", formatNumber/1000000];
    } else {
        numberString = [NSString stringWithFormat:@"%dB", formatNumber/1000000000];
    }
    
    return numberString;
}

- (NSString *)timeValue;
{
    NSString *timeString = [[NSString alloc]init];
    
    int time = [self intValue];
    
    int hours = time / 3600;
    int minutes = (time - hours * 3600) / 60;
    int seconds = time % 60;
    
    if (hours > 0) {
        timeString = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    } else {
        timeString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
    
    return timeString;
}

@end
