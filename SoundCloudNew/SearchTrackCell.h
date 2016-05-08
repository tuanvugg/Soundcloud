//
//  SearchTrackCell.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/25/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"

@protocol SearchTrackCellDelegate <NSObject>

- (void)buttonMoreDidTouch:(id)sender;

@end

@interface SearchTrackCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvArtwork;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayCount;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) id<SearchTrackCellDelegate> searchTrackCellDelegate;

- (IBAction)btnMoreTouched:(id)sender;

- (void)displayTrack:(Track *)track;

@end
