//
//  Track.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Genre.h"
#import "DBTrack.h"

@class DBTrack;
@interface Track : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *trackID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *streamURL;
@property (nonatomic, retain) NSNumber *playCount;
@property (nonatomic, retain) NSNumber *likeCount;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, copy) NSString *artworkURL;

- (instancetype)initWithJsonDict:(NSDictionary *)json;

- (instancetype)initWithDBTrack:(DBTrack *)dbTrack;


@end

