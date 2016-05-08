//
//  TrackListViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/31/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "TrackCell.h"
#import "TrackListViewController.h"
#import "Constant.h"
#import "NowPlayingViewController.h"

@interface TrackListViewController ()

@property(nonatomic,strong) UIBarButtonItem *barItem;

@end

@implementation TrackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Tracks";
    
    [self.navigationItem setHidesBackButton:TRUE];
    _barItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(btnDoneAllDidTouch)];
    self.navigationItem.leftBarButtonItem = _barItem;
    
    _tbvTracks.tableFooterView = [[UIView alloc]init];
    
    _tbvTracks.rowHeight = 60.0f;
    
}

- (void)btnDoneAllDidTouch;
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"trackCell";
    
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"TrackCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Track *track = _tracks[indexPath.row];
    [cell displayTrack:track];
    if ([_tracks[indexPath.row] isEqual:_playingTrack]) {
        UIImage *image = [[UIImage imageNamed:@"volume_max"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.btnMore setImage:image forState:UIControlStateNormal];
        cell.btnMore.tintColor = kAppColor;
    } else {
        cell.btnMore.hidden = YES;
    }
    
    
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NowPlayingViewController *nowPlayingViewController = [NowPlayingViewController sharedManager];
    nowPlayingViewController.trackList = _tracks;
    Track *selectedTrack = _tracks[indexPath.row];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
    if (![nowPlayingViewController.playingTrack.trackID isEqual: selectedTrack.trackID]) {
        nowPlayingViewController.playingTrack = selectedTrack;
        [nowPlayingViewController playTrack:nowPlayingViewController.playingTrack];
    }
    [self.navigationController popToViewController:nowPlayingViewController animated:NO];
    
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

@end
