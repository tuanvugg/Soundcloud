//
//  Playlist.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "Playlist.h"
#import "PlaylistTrack.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Constant.h"

@implementation Playlist

// Insert code here to add functionality to your managed object subclass

+ (Playlist *)createPlaylistWithTitle:(NSString *)title;
{
    Playlist *newPlaylist = nil;
    
    if (title.length > 0) {
        newPlaylist = [Playlist MR_createEntity];
        newPlaylist.title = title;
        newPlaylist.index = [Playlist getNextIndex];
        newPlaylist.artworkURL = @"";
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        
    }];
    
    return newPlaylist;
}
//
//+ (void)reIndexAllPlaylist;
//{
//    NSArray *playlists = [Playlist MR_findAllSortedBy:@"index" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]];
//    int idx = 2;
//    for (Playlist *playlist in playlists) {
//        playlist.index = [NSNumber numberWithInt:idx];
//        NSLog(@"%d",idx);
//        idx++;
//    }
//}

+ (NSNumber *)getNextIndex;
{
    Playlist *playlistWithHighestIndex = [Playlist MR_findFirstOrderedByAttribute:@"index" ascending:NO];
    return [NSNumber numberWithInt:[playlistWithHighestIndex.index intValue] + 1];
}

- (void)deletePlaylist;
{
    NSArray *playlistTracksToDelete = [PlaylistTrack MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",self.index]];
    for (PlaylistTrack *playlistTrack in playlistTracksToDelete) {
        [playlistTrack deletePlaylistTrack];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        if (contextDidSave) {
            NSLog(@"Data in default context SAVED");
        }
        if (error) {
            NSLog(@"Data in default context ERROR %@", error);
        }
    }];
    
    [self MR_deleteEntity];
}

+ (NSArray *)findAllPlaylists;
{
    return [Playlist MR_findAllSortedBy:@"index" ascending:YES];
}

@end
