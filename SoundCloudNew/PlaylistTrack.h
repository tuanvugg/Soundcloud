//
//  PlaylistTrack.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Playlist.h"
#import "DBTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistTrack : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (PlaylistTrack *)createPlaylistTrackWithPlaylist:(Playlist *)playlist andDBTrack:(DBTrack *)dbTrack;

- (void)deletePlaylistTrack;

+ (void)deleteAllPlaylistTracksInPlaylist:(Playlist *)playlist;


@end

NS_ASSUME_NONNULL_END

#import "PlaylistTrack+CoreDataProperties.h"
