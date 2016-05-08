//
//  SoundCloudAPI.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "SoundCloudAPI.h"
#import "Constant.h"
#import <AFNetworking/AFNetworking.h>

@interface SoundCloudAPI()

@property NSURLSessionConfiguration *configuration;
@property AFHTTPSessionManager *httpSessionManager;
@property NSDictionary *exploreGenreParameters;
@property NSMutableDictionary *exploreTrackParameters;
@property NSMutableDictionary *searchTrackParameters;
@property NSMutableDictionary *autoCompleteParameters;

@end

@implementation SoundCloudAPI

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SoundCloudAPI *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SoundCloudAPI alloc]init];
    });
    
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _httpSessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:_configuration];
        
        _exploreGenreParameters = @{
            @"client_id" : kSoundCloudAppID,
        };
        _exploreTrackParameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"client_id" : kSoundCloudAppID,
            @"tag" : @"out-of-experiment",
            @"offset" : @(kSoundCloudExploreDefaultOffset),
            @"limit" : @(kSoundCloudExploreDefaultLimit)
        }];
        _searchTrackParameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"client_id" : kSoundCloudAppID,
            @"order" : @"hotness",
            @"offset" : @(kSoundCloudSearchTrackDefaultOffset),
            @"limit" : @(kSoundCloudSearchTrackDefaultLimit),
            @"q" : @"default"
        }];
        _autoCompleteParameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"client_id" : kSoundCloudAppID,
            @"limit" : @(kSoundCloudAutoCompleteDefaultLimit),
            @"q" : @"default"
        }];
        
    }
    return self;
}

#pragma mark - Auto Complete
- (void)autoCompleteWithKeyWord:(NSString *)keyword completionBlock:(void(^)(NSArray *tracks))completion;
{
    if (keyword && keyword.length > 0) {
        _autoCompleteParameters[@"q"] = keyword;
        
        NSURLSessionDataTask *dataTask = [_httpSessionManager GET:kSoundCloudAutocompleteURL
                                                       parameters:_autoCompleteParameters progress:nil
                                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                              if (completion && responseObject && [keyword isEqualToString:_autoCompleteParameters[@"q"]]) {
                                                                  completion(responseObject[@"suggestions"]);
                                                              }
                                                          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                              NSLog(@"Can't autocomplete with error: %@", error);
                                                          }];
        
        [dataTask resume];
    }
}

#pragma mark - Search Tracks
- (void)searchTracksWithKeyWord:(NSString *)keyword offset:(int)offset completionBlock:(void(^)(NSArray *tracks))completion;
{
    if (keyword && keyword.length > 0) {
        _searchTrackParameters[@"q"] = keyword;
        _searchTrackParameters[@"offset"] = @(offset);
        
        NSURLSessionDataTask *dataTask = [_httpSessionManager GET:kSoundCloudSearchTrackURL
                                                       parameters:_searchTrackParameters progress:nil
                                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                              if (completion && responseObject && [keyword isEqualToString:_searchTrackParameters[@"q"]]) {
                                                                  completion(responseObject);
                                                              }
                                                          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                              NSLog(@"Can't search with error: %@", error);
                                                          }];
        [dataTask resume];
    }
    
}

#pragma mark - Explore Genres
- (void)exploreGenresWithCompletionBlock:(void(^)(NSArray *genreDict))completion;
{
    NSString *exploreGenreURL = [NSString stringWithFormat:kSoundCloudExploreURL,@"categories"];
    
    NSURLSessionDataTask *dataTask = [_httpSessionManager GET:exploreGenreURL
                                                   parameters:_exploreGenreParameters progress:nil
                                                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                          if(completion && responseObject){
                                                              completion(responseObject[@"music"]);
                                                          }
                                                      }
                                                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                          NSLog(@"Can't explore genres with error: %@", error);
                                                      }];
    [dataTask resume];
}

- (void)exploreTracksWithGenreCode:(NSString *)genreCode offset:(int)offset completionBlock:(void(^)(NSArray *tracks))completion;
{
    _exploreTrackParameters[@"offset"] = @(offset);
    
    NSString *exploreTracksURL = [NSString stringWithFormat:kSoundCloudExploreURL,genreCode];
    
    NSURLSessionDataTask *dataTask = [_httpSessionManager GET:exploreTracksURL
                                                   parameters:_exploreTrackParameters progress:nil
                                                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                          if (completion && responseObject) {
                                                              completion(responseObject[@"tracks"]);
                                                          }
                                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                          NSLog(@"Can't explore tracks with error: %@", error);
                                                      }];
    [dataTask resume];
}

@end
