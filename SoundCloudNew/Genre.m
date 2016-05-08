//
//  Genre.m
//  
//
//  Created by Trung Đức on 1/26/16.
//
//

#import <MagicalRecord/MagicalRecord.h>
#import "Genre.h"

@implementation Genre

// Insert code here to add functionality to your managed object subclass

+ (instancetype)creatWithCode:(NSString *)code;
{
    Genre *genre = [Genre MR_createEntity];
    
    genre.code = code;
    
    genre.name = [[code stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    if ([genre.name isEqualToString:@"Popular Music"]) {
        genre.name = @"Trending Music";
    }
    genre.artworkURL = @"";
    genre.index = [NSNumber numberWithInt:[Genre getNewNextIndex]];
    
    return genre;
}

+ (int)getNewNextIndex;
{
    Genre *genre = [Genre MR_findFirstOrderedByAttribute:@"index" ascending:NO];
    if (!genre) {
        return 1;
    } else {
        return [genre.index intValue] + 1;
    }
}

@end
