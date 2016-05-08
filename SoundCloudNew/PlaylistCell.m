//
//  PlaylistCell.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/28/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "PlaylistCell.h"
#import "Playlist.h"
#import "Constant.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PlaylistTrack.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation PlaylistCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayPlaylist:(Playlist *)playlist;
{
    _cellPlaylist = playlist;
    UIImage *image = [[UIImage imageNamed:kDefaultPlaylistImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imvArtwork setTintColor:kPlaylistDefaultImageColor];
    
    if ([playlist.artworkURL isEqualToString:@""]) {
        _imvArtwork.image = image;
    } else {
        [_imvArtwork sd_setImageWithURL:[NSURL URLWithString:playlist.artworkURL]
                       placeholderImage:image
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              }];
    }
    
    _lblTitle.text = playlist.title;
    int trackNumber = (int)[PlaylistTrack MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",playlist.index]];
    if (trackNumber > 1) {
        _lblTrackNumber.text = [NSString stringWithFormat:@"%d tracks",trackNumber];
    } else {
        _lblTrackNumber.text = [NSString stringWithFormat:@"%d track",trackNumber];
    }
}

- (void)displayBtnNewPlaylist;
{
    self.accessoryType = UITableViewCellAccessoryNone;
    UIImage *image = [[UIImage imageNamed:kBtnNewPlaylistImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imvArtwork setTintColor:kAppColor];
    _imvArtwork.image = image;
    _lblTrackNumber.text = @"";
    [_lblTitle setFont:[UIFont systemFontOfSize:20]];
    _lblTitle.text = kBtnNewPlaylistTitle;
}

@end
