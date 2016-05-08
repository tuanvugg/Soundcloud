//
//  PlaylistTrack+CoreDataProperties.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/28/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PlaylistTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistTrack (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *dbTrackID;
@property (nullable, nonatomic, retain) NSNumber *playlistIndex;
@property (nullable, nonatomic, retain) NSNumber *index;

@end

NS_ASSUME_NONNULL_END
