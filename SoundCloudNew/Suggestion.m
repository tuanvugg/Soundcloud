//
//  Suggestion.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/25/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "Suggestion.h"

@implementation Suggestion

- (instancetype)initWithJsonDict:(NSDictionary *)json;
{
    self = [self init];
    
    if (self) {
        NSString *query = json[@"query"];
        query = [query stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
        query = [query stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
        _query = query;
        _kind = json[@"kind"];
        _trackID = [json[@"id"] intValue];
        _score = [json[@"id"] intValue];
    }
    
    return self;
}

@end
