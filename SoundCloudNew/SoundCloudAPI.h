//
//  SoundCloudAPI.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <Foundation/Foundation.h>

#define sSoundCloudAPI [SoundCloudAPI sharedInstance]

@interface SoundCloudAPI : NSObject

+ (instancetype)sharedInstance;

- (void)exploreGenresWithCompletionBlock:(void(^)(NSArray *genreDict))completion;

- (void)exploreTracksWithGenreCode:(NSString *)genreCode offset:(int)offset completionBlock:(void(^)(NSArray *tracks))completion;

- (void)searchTracksWithKeyWord:(NSString *)keyword offset:(int)offset completionBlock:(void(^)(NSArray *tracks))completion;

- (void)autoCompleteWithKeyWord:(NSString *)keyword completionBlock:(void(^)(NSArray *tracks))completion;

@end
