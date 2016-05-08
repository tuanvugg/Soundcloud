//
//  GenreDetailViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/27/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "GenreDetailViewController.h"
#import <SVPullToRefresh.h>
#import "TrackCell.h"
#import "SoundCloudAPI.h"
#import "Constant.h"
#import "AppDelegate.h"
#import <MagicalRecord/MagicalRecord.h>
#import "AddToPlaylistViewController.h"
#import "NowPlayingViewController.h"
#import "UIImage+Custom.h"
#import "DownloadManagerViewController.h"
#import "Playlist.h"



@interface GenreDetailViewController () <TrackCellDelegate,DownloadDelegate>
{
    DownloadManagerViewController *DownloadingViewObj;
}
@property(nonatomic,assign) int currentOffset;
@property(nonatomic,strong) UIRefreshControl *refreshControl;

@end

@implementation GenreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    UINavigationController *DownloadingNav = [self.tabBarController.viewControllers objectAtIndex:4];
    DownloadingViewObj = [DownloadingNav.viewControllers objectAtIndex:0];
    [DownloadingViewObj setDelegate:self];
    
    DownloadingViewObj.downloadingArray = [[NSMutableArray alloc] init];
    DownloadingViewObj.sessionManager = [DownloadingViewObj backgroundSession];
    [DownloadingViewObj populateOtherDownloadTasks];

    
    [self updateDownloadingTabBadge];
    // Do any additional setup after loading the view.
    
    self.title = _selectedGenre.name;
    
    
    //hide separator line if cells are empty
    _tbvTracks.tableFooterView = [[UIView alloc]init];
    _tracks = [[NSMutableArray alloc]init];
    
    
    _currentOffset = 0;
    
    
    //setup tableview
    _tbvTracks.rowHeight = 60.0f;
    [_tbvTracks addInfiniteScrollingWithActionHandler:^{
        [self loadTracks];
    }];
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tbvTracks addSubview:_refreshControl];
    
    [self firstLoad];
    
}
- (void)refresh:(UIRefreshControl *)refreshControl {
    _currentOffset = 0;
    [_tracks removeAllObjects];
    [_tbvTracks reloadData];
    [self loadTracks];
}

- (void)firstLoad;
{
    NSArray *dbTracksWithSelectedGenre = [DBTrack MR_findAllSortedBy:@"createdAt" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"genreIndex = %@",_selectedGenre.index]];
    if (dbTracksWithSelectedGenre.count != 0) {
        for (DBTrack *dbTrack in dbTracksWithSelectedGenre) {
            Track *newTrack = [[Track alloc]initWithDBTrack:dbTrack];
            [_tracks addObject:newTrack];
        }
        _currentOffset += kSoundCloudExploreDLoadMore;
    } else {
        [_tbvTracks triggerInfiniteScrolling];
        [self loadTracks];
    }
}

- (void)loadTracks;
{
    __weak GenreDetailViewController *weakSelf = self;
    
    [sSoundCloudAPI exploreTracksWithGenreCode:_selectedGenre.code offset:_currentOffset completionBlock:^(NSArray *tracks) {
        //[DBTrack deleteAllDBTrackWithGenreIndex:_selectedGenre.index];
        for (NSDictionary *jsonDict in tracks) {
            
            //[DBTrack creatDBTrackWithJsonDict:jsonDict andGenreIndex:_selectedGenre.index];
            
            [_tbvTracks beginUpdates];
            
            NSIndexPath *indexPathInsert = [NSIndexPath indexPathForRow:_tracks.count inSection:0];
            [_tbvTracks insertRowsAtIndexPaths:@[indexPathInsert] withRowAnimation:UITableViewRowAnimationRight];
            Track *newTrack = [[Track alloc]initWithJsonDict:jsonDict];
            [_tracks addObject:newTrack];
            
            [_tbvTracks endUpdates];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tbvTracks.infiniteScrollingView stopAnimating];
            [weakSelf.refreshControl endRefreshing];
            weakSelf.tbvTracks.showsInfiniteScrolling = (_tracks.count > 0);
        });
        
        _currentOffset += kSoundCloudExploreDLoadMore;
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([NowPlayingViewController sharedManager].playingTrack) {
        
        UIImage *btnPlayingImage = [UIImage customWithTintColor:kAppColor duration:1.5];
        
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithImage:btnPlayingImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnPlayingDidTouch)];
        self.navigationItem.rightBarButtonItem = barItem;
    }  else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)btnPlayingDidTouch;
{
    NowPlayingViewController *nowPlayingViewController = [NowPlayingViewController sharedManager];
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.3f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [nowPlayingViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:nowPlayingViewController animated:NO];
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
    cell.trackCellDelegate = self;
    Track *track = _tracks[indexPath.row];
    [cell displayTrack:track];
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    NowPlayingViewController *nowPlayingViewController = [NowPlayingViewController sharedManager];
    nowPlayingViewController.trackList = _tracks;
    Track *selectedTrack = _tracks[indexPath.row];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [nowPlayingViewController setHidesBottomBarWhenPushed:YES];
    if (![nowPlayingViewController.playingTrack.trackID isEqual: selectedTrack.trackID]) {
        nowPlayingViewController.playingTrack = selectedTrack;
        [nowPlayingViewController playTrack:nowPlayingViewController.playingTrack];
    }
    [self.navigationController pushViewController:nowPlayingViewController animated:NO];
    

}

#pragma mark - TrackCell Delegate


- (void)buttonMoreDidTouch:(id)sender;
{
    TrackCell *cell = (TrackCell *)sender;
    NSIndexPath *indexPath =  [_tbvTracks indexPathForCell:cell];
    //show Action Sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add",@"Download",nil];
    
    
    //Change color button
    SEL selector = NSSelectorFromString(@"_alertController");
    if ([actionSheet respondsToSelector:selector])
    {
        UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]])
        {
            alertController.view.tintColor = kAppColor;
            
        }
    }
    else
    {
        // use other methods for iOS 7 or older.
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                button.titleLabel.textColor = kAppColor;
            }
        }
    }
    actionSheet.tag = indexPath.row;
    [actionSheet showInView:self.view];
    
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        AddToPlaylistViewController *addToPlaylistViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addToPlaylistID"];
        addToPlaylistViewController.track = [_tracks objectAtIndex:actionSheet.tag];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        [addToPlaylistViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:addToPlaylistViewController animated:NO];
    }
    if (buttonIndex == 1) {
        if (DownloadingViewObj.downloadingArray.count == 0) {
            [Playlist createPlaylistWithTitle:kTitlePlaylistDownload];
        }
        
        Track *Track = [_tracks objectAtIndex:actionSheet.tag];

        NSString *urlDownload = [NSString stringWithFormat:@"%@?client_id=%@",Track.streamURL,kSoundCloudAppID];
//
//        [DownloadingViewObj addDownloadTask:[NSString stringWithFormat:@"%@.mp3",Track.title] fileURL:urlDownload];
        [DownloadingViewObj addDownloadTask:Track];
        
        
        [self updateDownloadingTabBadge];
    }
    
}




- (void)updateDownloadingTabBadge
{
    UITabBarItem *downloadingTab = [self.tabBarController.tabBar.items objectAtIndex:4];
    NSUInteger badgeCount = DownloadingViewObj.downloadingArray.count;
    if(badgeCount == 0)
        [downloadingTab setBadgeValue:nil];
    else
        [downloadingTab setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)badgeCount]];
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
