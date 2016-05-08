//
//  Genre+CoreDataProperties.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/27/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Genre.h"

NS_ASSUME_NONNULL_BEGIN

@interface Genre (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *artworkURL;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
