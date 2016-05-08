//
//  DBTrack.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Track.h"
@class Track;
NS_ASSUME_NONNULL_BEGIN

@interface DBTrack : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (DBTrack *)createDBTrackWithTrack:(Track *)track;

+ (DBTrack *)creatDBTrackWithJsonDict:(NSDictionary *)json andGenreIndex:(NSNumber *)index;

+ (void)deleteAllDBTrackWithGenreIndex:(NSNumber *)index;

+ (DBTrack *)findFirstWithTrackID:(NSString *)trackID;

@end

NS_ASSUME_NONNULL_END

#import "DBTrack+CoreDataProperties.h"
