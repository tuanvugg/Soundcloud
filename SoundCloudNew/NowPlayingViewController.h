//
//  NowPlayingViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/30/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "Track.h"
#import <MarqueeLabel.h>

@interface NowPlayingViewController : MainViewController

@property(nonatomic,strong) NSMutableArray *trackList;
@property(nonatomic,strong) Track *playingTrack;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIImageView *imvArtWork;


@property (weak, nonatomic) IBOutlet UISlider *sliderProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayedTime;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainingTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderBufferring;


@property (weak, nonatomic) IBOutlet MarqueeLabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;


@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;

@property (weak, nonatomic) IBOutlet UIButton *btnRepeat;
@property (weak, nonatomic) IBOutlet UIButton *btnShuffle;
@property (weak, nonatomic) IBOutlet UIButton *btnListView;

- (IBAction)btnCancelDidTouch:(id)sender;
- (IBAction)btnPlayDidTouch:(id)sender;
- (IBAction)btnNextDidTouch:(id)sender;
- (IBAction)btnPreviousDidTouch:(id)sender;
- (IBAction)btnRepeatDidTouch:(id)sender;
- (IBAction)btnShuffleDidTouch:(id)sender;
- (IBAction)btnListViewDidTouch:(id)sender;
- (BOOL)isPlaying;


+ (NowPlayingViewController *)sharedManager;

- (void)playTrack:(Track *)playingTrack;



@end
