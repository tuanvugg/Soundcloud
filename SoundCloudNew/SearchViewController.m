//
//  SearchViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "SearchViewController.h"
#import "Constant.h"
#import <SVPullToRefresh.h>
#import "SoundCloudAPI.h"
#import "Track.h"
#import "SearchTrackCell.h"
#import "Suggestion.h"
#import "SuggestCell.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DBTrack.h"
#import "Playlist.h"
#import "AddToPlaylistViewController.h"
#import "PlayListTrack.h"
#import "NowPlayingViewController.h"
#import <Reachability.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "UIImage+Custom.h"


@interface SearchViewController () <SearchTrackCellDelegate>

@property(nonatomic,strong) NSMutableArray *searchResult;
@property(nonatomic,strong) NSMutableArray *suggestResult;
@property(nonatomic,assign) int searchOffset;
@property(nonatomic,strong) UIRefreshControl *refreshControl;
@property(nonatomic,strong) NSString *keywork;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _keywork = [[NSString alloc]init];
    
    //setup SearchBar
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_searchBar setTintColor:kAppColor];
    
    _searchResult = [[NSMutableArray alloc]init];
    _suggestResult = [[NSMutableArray alloc]init];
    
    _tblSearchResult.rowHeight = 60.0f;
    _tblSuggestResult.rowHeight = 40.0f;
    
    //hide separator line if cells are empty
    _tblSearchResult.tableFooterView = [[UIView alloc]init];
    _tblSuggestResult.tableFooterView = [[UIView alloc]init];
    
    
    //setup SVPullToRefresh when drag up
    [_tblSearchResult addInfiniteScrollingWithActionHandler:^{
        [self startSearch];
    }];
    
    //setup refresh data when drag down
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tblSearchResult addSubview:_refreshControl];
    
    _tblSuggestResult.hidden = YES;
    _tblSearchResult.hidden = YES;
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    _searchOffset = 0;
    [_searchResult removeAllObjects];
    [_tblSearchResult reloadData];
    [self startSearch];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar endEditing:YES];
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch;
{
    
    _tblSuggestResult.hidden = YES;
    _tblSearchResult.hidden = NO;
    __weak SearchViewController *weakSelf = self;
    [sSoundCloudAPI searchTracksWithKeyWord:_keywork offset:_searchOffset completionBlock:^(NSArray *tracks) {
        
        for (NSDictionary *jsonDict in tracks) {
            
            [_tblSearchResult beginUpdates];
            
            NSIndexPath *indexPathInsert = [NSIndexPath indexPathForRow:self.searchResult.count inSection:0];
            [_tblSearchResult insertRowsAtIndexPaths:@[indexPathInsert] withRowAnimation:UITableViewRowAnimationRight];
            Track *newTrack = [[Track alloc]initWithJsonDict:jsonDict];
            [_searchResult addObject:newTrack];
            [_tblSearchResult endUpdates];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tblSearchResult.infiniteScrollingView stopAnimating];
            [weakSelf.refreshControl endRefreshing];
            weakSelf.tblSearchResult.showsInfiniteScrolling = (_searchResult.count > 0);
        });
        
        _searchOffset += kSoundCloudSearchTrackLoadMore;
    }];
}


- (void)startAutoComplete;
{
    
    _tblSuggestResult.hidden = NO;
    
    [sSoundCloudAPI autoCompleteWithKeyWord:_searchBar.text completionBlock:^(NSArray *tracks) {
        
        NSMutableArray *tmpSuggestResult = [[NSMutableArray alloc]init];
        
        for (NSDictionary *jsonDict in tracks) {
            Suggestion *newSuggestion = [[Suggestion alloc]initWithJsonDict:jsonDict];
            [tmpSuggestResult addObject:newSuggestion];
        }
        _suggestResult = tmpSuggestResult;
        
        [_tblSuggestResult reloadData];
    }];
}

- (void)removeAllSearchData
{
    [_searchResult removeAllObjects];
    _searchOffset = 0;
    [_tblSearchResult reloadData];
}

- (void)removeAllSuggestData
{
    [_suggestResult removeAllObjects];
    [_tblSuggestResult reloadData];
}

+ (BOOL) isInternetConnectionAvailable
{
    Reachability *internet = [Reachability reachabilityWithHostName: @"www.google.com"];
    NetworkStatus netStatus = [internet currentReachabilityStatus];
    bool netConnection = false;
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"Access Not Available");
            netConnection = false;
            break;
        }
        case ReachableViaWWAN:
        {
            netConnection = true;
            break;
        }
        case ReachableViaWiFi:
        {
            netConnection = true;
            break;
        }
    }
    return netConnection;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([NowPlayingViewController sharedManager].playingTrack) {
        
        UIImage *btnPlayingImage = [UIImage customWithTintColor:kAppColor duration:1.5];
        
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithImage:btnPlayingImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnPlayingDidTouch)];
        self.navigationItem.rightBarButtonItem = barItem;
    } else {
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


#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [_searchBar becomeFirstResponder];
    [_searchBar setShowsCancelButton:YES animated:YES];
    
    if ([_searchBar.text isEqualToString:@""]) {
        _tblSuggestResult.hidden = YES;
    } else {
        _tblSuggestResult.hidden = NO;
    }
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    _tblSuggestResult.hidden = YES;
    _keywork = _searchBar.text;
    _tblSearchResult.hidden = NO;
    [_searchBar endEditing:YES];
    
    [self removeAllSearchData];
    [_tblSearchResult triggerInfiniteScrolling];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self startAutoComplete];
    if ([_searchBar.text isEqualToString:@""]) {
        _tblSuggestResult.hidden = YES;
        _tblSearchResult.hidden = YES;
        [self removeAllSearchData];
        [self removeAllSuggestData];
        _keywork = @"";
        _searchBar.text = @"";
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [_searchBar endEditing:YES];
    _tblSuggestResult.hidden = YES;
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tblSearchResult) {
        return _searchResult.count;
    } else {
        return _suggestResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tblSearchResult) {
        static NSString *cellId = @"trackCell";
        
        SearchTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"SearchTrackCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        Track *track = _searchResult[indexPath.row];
        [cell displayTrack:track];
        
        cell.searchTrackCellDelegate = self;
        
        return cell;
    } else {
        static NSString *cellId = @"suggestionCell";
        
        SuggestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"SuggestCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        Suggestion *suggestion = _suggestResult[indexPath.row];
        [cell displaySuggestion:suggestion];
        
        
        
        return cell;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (tableView == _tblSearchResult) {
        NowPlayingViewController *nowPlayingViewController = [NowPlayingViewController sharedManager];
        nowPlayingViewController.trackList = _searchResult;
        Track *selectedTrack = _searchResult[indexPath.row];
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
        
    } else {
        
        Suggestion *suggestion = _suggestResult[indexPath.row];
        _searchBar.text = suggestion.query;
        _keywork = suggestion.query;
        [_searchBar endEditing:YES];
        _tblSuggestResult.hidden = YES;
        [self removeAllSearchData];
        [_tblSearchResult triggerInfiniteScrolling];
    }
}

#pragma mark - Search Track Cell Delegate

- (void)buttonMoreDidTouch:(id)sender;
{
    SearchTrackCell *cell = (SearchTrackCell *)sender;
    NSIndexPath *indexPath =  [_tblSearchResult indexPathForCell:cell];
    
    //show Action Sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add",nil];
    
    
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
        addToPlaylistViewController.track = [_searchResult objectAtIndex:actionSheet.tag];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        [addToPlaylistViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:addToPlaylistViewController animated:NO];
    }
    
}



@end
