//
//  DBTrack.m
//
//
//  Created by Trung Đức on 1/26/16.
//
//

#import "DBTrack.h"
#import "Track.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation DBTrack

// Insert code here to add functionality to your managed object subclass

+ (DBTrack *)createDBTrackWithTrack:(Track *)track;
{
    DBTrack *newDBTrack = nil;
    
    if ([DBTrack findFirstWithTrackID:track.trackID]) {
        newDBTrack = [DBTrack MR_findFirstByAttribute:@"dbTrackID" withValue:track.trackID];
        newDBTrack.createdAt = [NSDate date];
        newDBTrack.playCount = track.playCount;
    } else {
        newDBTrack = [DBTrack MR_createEntity];
        
        newDBTrack.artworkURL = track.artworkURL;
        newDBTrack.createdAt = [NSDate date];
        newDBTrack.duration = track.duration;
        newDBTrack.userName = track.userName;
        newDBTrack.playCount = track.playCount;
        newDBTrack.streamURL = track.streamURL;
        newDBTrack.title = track.title;
        newDBTrack.dbTrackID = track.trackID;
        newDBTrack.genreIndex = [NSNumber numberWithInt:0];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
    
    return newDBTrack;
}

+ (DBTrack *)creatDBTrackWithJsonDict:(NSDictionary *)json andGenreIndex:(NSNumber *)index;
{
    DBTrack *newDBTrack = [DBTrack MR_createEntity];
    
    newDBTrack.title = json[@"title"];
    newDBTrack.duration = [NSNumber numberWithInt:[json[@"duration"] intValue]/1000];
    if ([json[@"playback_count"] isKindOfClass:[NSNull class]]) {
        newDBTrack.playCount = [NSNumber numberWithInt:0];
    } else {
        newDBTrack.playCount = [NSNumber numberWithInt:[json[@"playback_count"] intValue]];
    }
    
    if ([json[@"artwork_url"] isKindOfClass:[NSNull class]]) {
        newDBTrack.artworkURL = @"";
    } else {
        newDBTrack.artworkURL = json[@"artwork_url"];
    }
    newDBTrack.userName = json[@"user"][@"username"];
    newDBTrack.dbTrackID = [NSString stringWithFormat:@"%@",json[@"id"]];
    
    if ([json[@"stream_url"] isKindOfClass:[NSNull class]]) {
        newDBTrack.streamURL =@"";
    } else {
        newDBTrack.streamURL = json[@"stream_url"];
    }
    newDBTrack.createdAt = [NSDate date];
    newDBTrack.genreIndex = index;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
    
    return newDBTrack;
}



+ (DBTrack *)findFirstWithTrackID:(NSString *)trackID {
    DBTrack *track = [DBTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dbTrackID = %@ AND genreIndex = %@",trackID,[NSNumber numberWithInt:0]]];
    return track;
}

+ (void)deleteAllDBTrackWithGenreIndex:(NSNumber *)index;
{
    [DBTrack MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"genreIndex = %@",index]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
}

@end
