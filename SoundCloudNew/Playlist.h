//
//  Playlist.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Playlist : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (Playlist *)createPlaylistWithTitle:(NSString *)title;

- (void)deletePlaylist;

@end

NS_ASSUME_NONNULL_END

#import "Playlist+CoreDataProperties.h"
