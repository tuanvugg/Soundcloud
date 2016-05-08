//
//  TrackCell.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/26/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"
#import "DBTrack.h"

@protocol TrackCellDelegate <NSObject>

- (void)buttonMoreDidTouch:(id)sender;
- (void)buttonDownloadDidTouch:(id)sender;

@end

@interface TrackCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvArtwork;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUserNameOrGenre;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayCount;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) id<TrackCellDelegate> trackCellDelegate;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;

- (IBAction)btnDownloadTouched:(id)sender;

- (IBAction)btnMoreTouched:(id)sender;

- (void)displayTrack:(Track *)track;

- (void)displayDBTrack:(DBTrack *)track;

@end
