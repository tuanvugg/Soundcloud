//
//  Track.m
//
//
//  Created by Trung Đức on 1/24/16.
//
//

#import "Track.h"
#import "Genre.h"
#import "DBTrack.h"


@implementation Track

- (instancetype)initWithJsonDict:(NSDictionary *)json;
{
    self = [self init];
    
    if (self) {
        self.title = json[@"title"];
        self.duration = [NSNumber numberWithInt:[json[@"duration"] intValue]/1000];
        if ([json[@"likes_count"] isKindOfClass:[NSNull class]]) {
            self.likeCount = [NSNumber numberWithInt:0];
        } else {
            self.likeCount = [NSNumber numberWithInt:[json[@"likes_count"] intValue]];
        }
        if ([json[@"playback_count"] isKindOfClass:[NSNull class]]) {
            self.playCount = [NSNumber numberWithInt:0];
        } else {
            self.playCount = [NSNumber numberWithInt:[json[@"playback_count"] intValue]];
        }
        
        if ([json[@"artwork_url"] isKindOfClass:[NSNull class]]) {
            self.artworkURL = @"";
        } else {
            self.artworkURL = json[@"artwork_url"];
        }
        self.userName = json[@"user"][@"username"];
        self.trackID = [NSString stringWithFormat:@"%@",json[@"id"]];
        self.streamURL = json[@"stream_url"];
    }
    
    return self;
}

- (instancetype)initWithDBTrack:(DBTrack *)dbTrack;
{
    self = [self init];
    
    if (self) {
        self.title = dbTrack.title;
        self.duration = dbTrack.duration;
        self.likeCount = [NSNumber numberWithInt:0];
        self.playCount = dbTrack.playCount;
        
        self.artworkURL = dbTrack.artworkURL;
        self.userName = dbTrack.userName;
        self.trackID =dbTrack.dbTrackID;
        self.streamURL = dbTrack.streamURL;
    }
    
    return self;
}


@end

