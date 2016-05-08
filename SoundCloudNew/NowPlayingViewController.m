//
//  NowPlayingViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/30/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "Constant.h"
#import <AVFoundation/AVFoundation.h>
#import "Playlist.h"
#import <MagicalRecord/MagicalRecord.h>
#import "PlaylistTrack.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSNumber+SoundCloud.h"
#import "TrackListViewController.h"

#define kTracksKey              @"tracks"
#define kStatusKey              @"status"
#define kRateKey                @"rate"
#define kPlayableKey            @"playable"
#define kCurrentItemKey         @"currentItem"
#define kTimedMetadataKey       @"currentItem.timedMetadata"
#define kLoadedTimeRanges       @"currentItem.loadedTimeRanges"
#define kPlaybackBufferEmpty    @"playbackBufferEmpty"
#define kPlaybackKeepUp         @"playbackLikelyToKeepUp"
#import <MarqueeLabel/MarqueeLabel.h>

@interface NowPlayingViewController (){
    id timeObserver;
    
    CGFloat percentage;
    CGFloat percentageBuffering;
    Boolean sliderProgressEditing;
    Boolean requesting;
}



@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem *currentPlayingItem;

@end

@implementation NowPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sliderBufferring.userInteractionEnabled = NO;
    
//    UIImage *imageThumb = [[UIImage imageNamed:kThumbSliderImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [_sliderProgress setThumbImage:imageThumb forState:UIControlStateNormal];
//    
    _lblTitle.marqueeType = MLContinuous;
    _lblTitle.animationDelay = 2.0f;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    sliderProgressEditing = NO;
    
    UIImage *image = [[UIImage imageNamed:@"MoreButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_btnListView setImage:image forState:UIControlStateNormal];
    _btnListView.tintColor = kAppColor;
    
    
    UIImage *imageShuffle = [[UIImage imageNamed:@"audio_shuffle_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_btnShuffle setImage:imageShuffle forState:UIControlStateSelected];
    _btnShuffle.tintColor = kAppColor;
    
    UIImage *imageRepeat = [[UIImage imageNamed:@"repeat_one"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_btnRepeat setImage:imageRepeat forState:UIControlStateSelected];
    _btnRepeat.tintColor = kAppColor;
    // Do any additional setup after loading the view.
    [self playTrack:_playingTrack];
    
}

+ (NowPlayingViewController *)sharedManager
{
    static NowPlayingViewController *shaderManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        shaderManager = [storyboard instantiateViewControllerWithIdentifier:@"nowPlayingID"];
    });
    return shaderManager;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    UIEventSubtype rc = event.subtype;
    if (rc == UIEventSubtypeRemoteControlTogglePlayPause) {
        if (!requesting) {
            if (self.btnPlay.selected) {
                //music playing
                //now pause
                [self play];
            } else {
                [self pause];
            }
        }
    } else if (rc == UIEventSubtypeRemoteControlPlay) {
        [self play];
    } else if (rc == UIEventSubtypeRemoteControlPause) {
        [self pause];
    } else if (rc == UIEventSubtypeRemoteControlNextTrack) {
        if (_btnShuffle.selected) {
            _playingTrack = _trackList[arc4random() % _trackList.count];
            [self playTrack:_playingTrack];
        } else {
            _playingTrack = _trackList[[_trackList indexOfObject:_playingTrack] + 1];
            [self playTrack:_playingTrack];
        }
    } else if (rc == UIEventSubtypeRemoteControlPreviousTrack){
        if (_btnShuffle.selected) {
            _playingTrack = _trackList[arc4random() % _trackList.count];
            [self playTrack:_playingTrack];
        } else {
            _playingTrack = _trackList[[_trackList indexOfObject:_playingTrack] - 1];
            [self playTrack:_playingTrack];
        }
    }
}

- (void)playURL:(NSURL *)streamingURL;
{
    AVPlayerItem *newItem = [AVPlayerItem playerItemWithURL:streamingURL];
    self.currentPlayingItem = newItem;
    
    if (self.player == nil) {
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.currentPlayingItem];
        
        [self.player addObserver:self forKeyPath:kLoadedTimeRanges
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
        
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:nil];
        
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:nil];
        
        
        
    } else {
        
        [self.player replaceCurrentItemWithPlayerItem:self.currentPlayingItem];
    }
    
    [self.currentPlayingItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionNew context:nil];
    /* Observer buffer status */
    [self.currentPlayingItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayingItem addObserver:self forKeyPath:kPlaybackKeepUp options:NSKeyValueObservingOptionNew context:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayingItem];
    
    
    __weak NowPlayingViewController *weakSelf = self;
    
    timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0f, 1.0f) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        CGFloat currentTime = CMTimeGetSeconds(time);
        
        if (weakSelf.currentPlayingItem) {
            //get duration
            percentage = currentTime / CMTimeGetSeconds(_currentPlayingItem.duration);
            [weakSelf updateGUI];
            
        }
        
    }];
    
    
    [self.player play];
    
    
}

- (void)updateGUI;
{
    if (_currentPlayingItem) {
        
        if (!sliderProgressEditing) {
            _sliderProgress.enabled = YES;
            
            requesting = NO;
            
            //update slider progress
            self.sliderProgress.value = percentage;
            
            //update time text
            CGFloat playedTime = percentage * CMTimeGetSeconds(_currentPlayingItem.duration);
            self.lblPlayedTime.text = [self formatTime:playedTime];
            
            CGFloat remainingTime = CMTimeGetSeconds(_currentPlayingItem.duration) - playedTime;
            self.lblRemainingTime.text = [NSString stringWithFormat:@"-%@",[self formatTime:remainingTime]];
        } else {
            
            CGFloat playedTime = _sliderProgress.value * CMTimeGetSeconds(_currentPlayingItem.duration);
            self.lblPlayedTime.text = [self formatTime:playedTime];
            
            CGFloat remainingTime = CMTimeGetSeconds(_currentPlayingItem.duration) - playedTime;
            self.lblRemainingTime.text = [NSString stringWithFormat:@"-%@",[self formatTime:remainingTime]];
        }
    } else {
        self.sliderProgress.value = 0;
        
        self.lblPlayedTime.text = @"--:--";
        self.lblRemainingTime.text = @"--:--";
    }
    
    //update play/pause status
    if ([self isPlaying]) {
        [self.btnPlay setSelected:NO];
    } else {
        [self.btnPlay setSelected:YES];
    }
    
}


- (BOOL)isPlaying;
{
    if (self.player && self.currentPlayingItem && self.player.rate != 0.0f) {
        return YES;
    }
    
    return NO;
    
}

- (void)playTrack:(Track *)playingTrack;
{
    
    [self resetPlayer];
    
    
    
    UIImage *image = [[UIImage imageNamed:kDefaultTrackImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imvArtWork setTintColor:kAppColor];
    
    if ([playingTrack.artworkURL isEqualToString:@""]) {
        _imvArtWork.image = image;
    } else {
        
        UIImageView *placeholder = [[UIImageView alloc]init];
        [placeholder sd_setImageWithURL:[NSURL URLWithString:playingTrack.artworkURL] placeholderImage:image];
        
    NSString *artworkString = [playingTrack.artworkURL stringByReplacingOccurrencesOfString:@"large" withString:@"crop"];
        
    [_imvArtWork sd_setImageWithURL:[NSURL URLWithString:artworkString]
                   placeholderImage:placeholder.image
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    }
    
    _lblUserName.text = playingTrack.userName;
    _lblUserName.textColor = kAppColor;
    _lblTitle.text = playingTrack.title;
    _lblTitle.textColor = kAppColor;
    _lblRemainingTime.text = [NSString stringWithFormat:@"-%@",[playingTrack.duration timeValue]];
    _sliderProgress.value = 0;
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@?client_id=%@",playingTrack.streamURL,kSoundCloudAppID];
    
    Playlist *historyPlaylist = [Playlist MR_findFirstByAttribute:@"index" withValue:kHistoryPlaylistIndex];
    DBTrack *dbTrack = [DBTrack createDBTrackWithTrack:playingTrack];
    [PlaylistTrack createPlaylistTrackWithPlaylist:historyPlaylist andDBTrack:dbTrack];
    
    [self playURL:[NSURL URLWithString:stringUrl]];
}

- (IBAction)btnCancelDidTouch:(id)sender;
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)play;
{
    _btnPlay.selected =FALSE;
    [self.player play];
}

- (void)pause;
{
    _btnPlay.selected = TRUE;
    [self.player pause];
}

- (NSString *)formatTime:(CGFloat)time;
{
    NSInteger hours = time / 3600;
    NSInteger seconds = (NSInteger)time % 60;
    NSInteger minutes = (time - hours * 3600 - seconds) / 60;
    
    NSString *finalString = nil;
    if (hours > 0) {
        finalString = [NSString stringWithFormat:@"%ld:%02ld:%02ld", hours, minutes, (long)seconds];
    } else {
        finalString = [NSString stringWithFormat:@"%ld:%02ld", minutes, (long)seconds];
    }
    
    
    return finalString;
    
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    
    
    if (_btnRepeat.selected) {
        [self playTrack:_playingTrack];
    } else {
        if (_btnShuffle.selected) {
            _playingTrack = _trackList[arc4random() % _trackList.count];
            [self playTrack:_playingTrack];
        } else {
            if ([[_trackList lastObject] isEqual:_playingTrack]) {
                [self playTrack:_trackList[0]];
            } else {
                _playingTrack = _trackList[[_trackList indexOfObject:_playingTrack] + 1];
                [self playTrack:_playingTrack];
            }
        }
    }
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.currentPlayingItem) {
        if ([keyPath isEqualToString:kStatusKey]) {
            if (self.currentPlayingItem.status == AVPlayerItemStatusFailed) {
                
                
                NSLog(@"------player item failed:%@",self.currentPlayingItem.error);
                [self itemDidFailedToPlay:nil];
                
            } else if (self.currentPlayingItem.status == AVPlayerItemStatusReadyToPlay){
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                
                //[self itemWillPlaying];
                
            } else {
                // Unknow
            }
            
        }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]){
            [self itemDidBufferEmpty];
            
        }else if ([keyPath isEqualToString:kPlaybackKeepUp]){
            if (self.currentPlayingItem.playbackLikelyToKeepUp || self.currentPlayingItem.playbackBufferFull)
            {
                NSLog(@"CONTINUE PLAY...");
                [self itemDidKeepUp];
            }
            else
            {
                NSLog(@"BUFFERRING...");
            }
        }
    }
    else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
        
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && ![timeRanges isKindOfClass:[NSNull class]] && [timeRanges count] > 0)
        {
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            percentageBuffering = CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration)) / CMTimeGetSeconds(_currentPlayingItem.duration);
            
            NSLog(@"percentageBuffering: %.2f", percentageBuffering);
            
            
            if (isnan(percentageBuffering) || isinf(percentageBuffering)) {
                return;
            }
            
            [self updateGUI];
            
        }
        
    }
}

- (void)itemDidFailedToPlay:(NSNotification *)notification{
    ////show status to fail
    
}

- (void)itemDidBufferEmpty {
    
}

- (void)itemDidKeepUp {
    if (self.currentPlayingItem.playbackLikelyToKeepUp || self.currentPlayingItem.playbackBufferFull) {
        [self play];
        
    }
}

//- (void)itemWillPlaying;
//{
//    _sliderProgress.enabled = FALSE;
//}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sliderProgressDidChangeValue:(id)sender;
{
    
    //get new progress
    CGFloat newProgress = self.sliderProgress.value;
    
    CGFloat newPercentage = newProgress / (self.sliderProgress.maximumValue - self.sliderProgress.minimumValue);
    
    
    //seek player to new time
    CGFloat newCurrentTime = newPercentage * CMTimeGetSeconds(_currentPlayingItem.duration);
    
    //seel
    [self.player seekToTime:CMTimeMakeWithSeconds(newCurrentTime, 1.0f)];
    
    
    
    
}

- (IBAction)sliderProgressDidTouchDown:(id)sender {
    sliderProgressEditing = YES;
    [self.player pause];
}

- (IBAction)sliderProgressDidTouchUp:(id)sender {
    sliderProgressEditing = NO;
    [self.player play];
    
}





- (IBAction)btnPlayDidTouch:(id)sender {
        //pause/play
        //if
        //toggle play/pause
        ///is showing Play:, music is pausing., btn normal.
        // is showing pause, musci is playing, btn selected
    if (!requesting) {
        if (self.btnPlay.selected) {
            //music playing
            //now pause
            [self play];
        } else {
            [self pause];
        }
    }
}

- (void)resetPlayer
{
    // Remove timeobserver if exist
    if (timeObserver)
    {
        if (self.player) {
            [self.player removeTimeObserver:timeObserver];
        }
        timeObserver = nil;
    }
    
    // Replace currentItem with nil
    if (self.player) {
        [self.player pause];
        [self.player setRate:0.0f];
        
        [self.player removeObserver:self forKeyPath:kLoadedTimeRanges];
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
        [self.player removeObserver:self forKeyPath:kRateKey];
        
        self.player = nil;
        
        
        
    }
    
    if (self.currentPlayingItem) {
        
        [self.currentPlayingItem removeObserver:self forKeyPath:kStatusKey];
        [self.currentPlayingItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
        [self.currentPlayingItem removeObserver:self forKeyPath:kPlaybackKeepUp];
        
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayingItem];
        
        self.currentPlayingItem = nil;
    }
    
    
    //reset GUI
    self.sliderProgress.value = 0.0f;
    
    percentage = 0;
    
    self.lblPlayedTime.text = @"--:--";
    self.lblRemainingTime.text = @"--:--";
    
    [self updateGUI];
    
    _sliderProgress.enabled = NO;
    
    requesting = YES;
    
}

- (IBAction)btnNextDidTouch:(id)sender {
    
    
    if (_btnShuffle.selected) {
        _playingTrack = _trackList[arc4random() % _trackList.count];
        [self playTrack:_playingTrack];
    } else {
        if ([[_trackList lastObject] isEqual:_playingTrack]) {
            [self playTrack:_trackList[0]];
        } else {
            _playingTrack = _trackList[[_trackList indexOfObject:_playingTrack] + 1];
            [self playTrack:_playingTrack];
        }
    }
    
}

- (IBAction)btnPreviousDidTouch:(id)sender {
    
    
    if (_btnShuffle.selected) {
        _playingTrack = _trackList[arc4random() % _trackList.count];
        [self playTrack:_playingTrack];
    } else {
        if ([[_trackList firstObject] isEqual:_playingTrack]) {
            [self playTrack:_trackList[_trackList.count]];
        } else {
            _playingTrack = _trackList[[_trackList indexOfObject:_playingTrack] - 1];
            [self playTrack:_playingTrack];
        }
    }
    
}

- (IBAction)btnRepeatDidTouch:(id)sender {
    
    if (_btnRepeat.selected) {
        _btnRepeat.selected = FALSE;
    } else {
        _btnRepeat.selected = TRUE;
    }
}

- (IBAction)btnShuffleDidTouch:(id)sender {
    if (_btnShuffle.selected) {
        _btnShuffle.selected = FALSE;
    } else {
        _btnShuffle.selected = TRUE;
    }
}

- (IBAction)btnListViewDidTouch:(id)sender {
    
    TrackListViewController *trackListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"trackListID"];
    trackListViewController.tracks = _trackList;
    trackListViewController.playingTrack = _playingTrack;
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [trackListViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:trackListViewController animated:NO];
    
}
@end
