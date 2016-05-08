//
//  Genre.h
//  
//
//  Created by Trung Đức on 1/26/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Genre : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (instancetype)creatWithCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END

#import "Genre+CoreDataProperties.h"
