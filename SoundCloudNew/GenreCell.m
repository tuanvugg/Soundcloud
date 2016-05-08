//
//  GenreCell.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/27/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "Genre.h"
#import "GenreCell.h"
#import <UIImageView+WebCache.h>
#import "Constant.h"

@implementation GenreCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayGenre:(Genre *)genre;
{
    _lblGenreTitle.text = genre.name;
    
    UIImage *image = [[UIImage imageNamed:kDefaultGenreImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imvGenre setTintColor:kAppColor];
    
    if ([genre.artworkURL isEqualToString:@""]) {
        _imvGenre.image = image;
    } else {
        [_imvGenre sd_setImageWithURL:[NSURL URLWithString:genre.artworkURL]
                     placeholderImage:image
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    
}

@end
