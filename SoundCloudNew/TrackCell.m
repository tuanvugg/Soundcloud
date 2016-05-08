//
//  TrackCell.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "TrackCell.h"
#import <UIImageView+WebCache.h>
#import "NSNumber+SoundCloud.h"
#import <Masonry/Masonry.h>
#import "Constant.h"

@implementation TrackCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _lblDuration.backgroundColor = [UIColor darkTextColor];
}

- (void)displayTrack:(Track *)track;
{
    UIImage *image = [[UIImage imageNamed:kDefaultTrackImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imvArtwork setTintColor:kAppColor];
    
    if ([track.artworkURL isEqualToString:@""]) {
        _imvArtwork.image = image;
    } else {
        [_imvArtwork sd_setImageWithURL:[NSURL URLWithString:track.artworkURL]
                       placeholderImage:image
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              }];
    }
    
    
    //setup Duration Label
    _lblDuration.layer.cornerRadius = 2.2f;
    _lblDuration.layer.masksToBounds = TRUE;
    _lblDuration.text = [track.duration timeValue];
    CGSize labelSize = [_lblDuration.text sizeWithAttributes:@{NSFontAttributeName:_lblDuration.font}];
    CGFloat labelWidth = labelSize.width;
    [_lblDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth+5.0f);
    }];
    
    
    _lblPlayCount.text = [track.playCount stringFormatValue];
    _lblTitle.text = track.title;
    _lblUserNameOrGenre.text = track.userName;
    
    [_btnMore setImage:[[UIImage imageNamed:kBtnMoreImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _btnMore.tintColor = kAppColor;
    
}

- (void)displayDBTrack:(DBTrack *)track;
{
    UIImage *image = [[UIImage imageNamed:kDefaultTrackImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imvArtwork setTintColor:kAppColor];
    
    if ([track.artworkURL isEqualToString:@""]) {
        _imvArtwork.image = image;
    } else {
        [_imvArtwork sd_setImageWithURL:[NSURL URLWithString:track.artworkURL]
                       placeholderImage:image
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              }];
    }
    
    
    
    //setup Duration Label
    _lblDuration.layer.cornerRadius = 2.2f;
    _lblDuration.layer.masksToBounds = TRUE;
    _lblDuration.text = [track.duration timeValue];
    CGSize labelSize = [_lblDuration.text sizeWithAttributes:@{NSFontAttributeName:_lblDuration.font}];
    CGFloat labelWidth = labelSize.width;
    [_lblDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth+5.0f);
    }];
    
    
    _lblPlayCount.text = [track.playCount stringFormatValue];
    _lblTitle.text = track.title;
    _lblUserNameOrGenre.text = track.userName;
    
    [_btnMore setImage:[[UIImage imageNamed:kBtnMoreImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _btnMore.tintColor = kAppColor;
    
}

- (IBAction)btnDownloadTouched:(id)sender;
{
    [_trackCellDelegate buttonDownloadDidTouch:self];
}

- (IBAction)btnMoreTouched:(id)sender {
    [_trackCellDelegate buttonMoreDidTouch:self];
}
@end
