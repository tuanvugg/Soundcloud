//
//  PlaylistTrack.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "PlaylistTrack.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation PlaylistTrack

// Insert code here to add functionality to your managed object subclass

+ (PlaylistTrack *)createPlaylistTrackWithPlaylist:(Playlist *)playlist andDBTrack:(DBTrack *)dbTrack;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playlistIndex = %@ AND dbTrackID = %@",playlist.index,dbTrack.dbTrackID];
    PlaylistTrack *newPlaylistTrack = nil;
    if ([PlaylistTrack MR_countOfEntitiesWithPredicate:predicate]) {
        newPlaylistTrack = [PlaylistTrack MR_findFirstWithPredicate:predicate];
        newPlaylistTrack.createdAt = [NSDate date];
    } else {
        newPlaylistTrack = [PlaylistTrack MR_createEntity];
        newPlaylistTrack.createdAt = [NSDate date];
        newPlaylistTrack.playlistIndex = playlist.index;
        newPlaylistTrack.playlistIndex = playlist.index;
        newPlaylistTrack.dbTrackID = dbTrack.dbTrackID;
        
        if ([Playlist MR_countOfEntities] != 0) {
            PlaylistTrack *firstInPlaylist = [PlaylistTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",playlist.index] sortedBy:@"createdAt" ascending:YES];
            DBTrack *dbTrack = [DBTrack MR_findFirstOrCreateByAttribute:@"dbTrackID" withValue:firstInPlaylist.dbTrackID];
            playlist.artworkURL = dbTrack.artworkURL;
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
    
    return newPlaylistTrack;
}

+ (void)deleteAllPlaylistTracksInPlaylist:(Playlist *)playlist;
{
    NSArray *playlistTrackToDelete = [PlaylistTrack MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",playlist.index]];
    
    for (PlaylistTrack *playlistTrack in playlistTrackToDelete) {
        [playlistTrack deletePlaylistTrack];
    }
    playlist.artworkURL = @"";
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
}

- (void)deletePlaylistTrack;
{
    NSNumber *playlistIndex = self.playlistIndex;
    [self MR_deleteEntity];
    PlaylistTrack *firstInPlaylist = [PlaylistTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",playlistIndex] sortedBy:@"createdAt" ascending:YES];
    DBTrack *dbTrack = [DBTrack MR_findFirstOrCreateByAttribute:@"dbTrackID" withValue:firstInPlaylist.dbTrackID];
    Playlist *playlist = [Playlist MR_findFirstByAttribute:@"index" withValue:playlistIndex];
    
    playlist.artworkURL = dbTrack.artworkURL;
    
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
}

@end
