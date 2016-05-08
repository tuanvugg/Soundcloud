//
//  DBTrack+CoreDataProperties.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/27/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBTrack (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *artworkURL;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *dbTrackID;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSNumber *playCount;
@property (nullable, nonatomic, retain) NSString *streamURL;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSNumber *genreIndex;

@end

NS_ASSUME_NONNULL_END
