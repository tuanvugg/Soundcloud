//
//  PlaylistDetailViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/30/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "PlaylistDetailViewController.h"
#import "Constant.h"
#import <MagicalRecord/MagicalRecord.h>
#import "PlaylistTrack.h"
#import "TrackCell.h"
#import "AddToPlaylistViewController.h"
#import "NowPlayingViewController.h"
#import "UIImage+Custom.h"

typedef NS_ENUM(NSInteger, buttonType) {
    btnAddIndex = 0,
    btnDeleteIndex
};

@interface PlaylistDetailViewController () <NSFetchedResultsControllerDelegate,TrackCellDelegate>

@property(nonatomic,strong) NSMutableArray *tracks;
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,strong) UIBarButtonItem *barItem;

@end

@implementation PlaylistDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _selectedPlaylist.title;
    
    _tblPlaylistTracks.tableFooterView = [[UIView alloc]init];
    
    //setup SearchBar
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_searchBar setTintColor:kAppColor];
    
    _tracks = [[NSMutableArray alloc]init];
    
    _tblPlaylistTracks.rowHeight = 60.0f;
    
    UIImage *image = [[UIImage imageNamed:kBtnRemoveAllImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _barItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(btnRemoveAllDidTouch)];
    
    _fetchedResultsController = [PlaylistTrack MR_fetchAllSortedBy:@"createdAt"
                                                         ascending:YES
                                                     withPredicate: [NSPredicate predicateWithFormat:@"playlistIndex = %@",_selectedPlaylist.index]
                                                           groupBy:nil
                                                          delegate:self];
    
    [self reloadAllTracksWillReloadTableView:YES];
    
}

//- (void)viewWillAppear:(BOOL)animated{
//    [self viewWillAppear:animated];
//    
//}

- (void)btnRemoveAllDidTouch;{
    
    [PlaylistTrack deleteAllPlaylistTracksInPlaylist:_selectedPlaylist];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar endEditing:YES];
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)reloadAllTracksWillReloadTableView:(BOOL)willReloadTable;
{
    [_tracks removeAllObjects];
    NSArray *playlistTracks = [PlaylistTrack MR_findAllSortedBy:@"createdAt" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",_selectedPlaylist.index]];
    for (PlaylistTrack *playlistTrack in playlistTracks) {
        DBTrack *dbTrack = [DBTrack findFirstWithTrackID:playlistTrack.dbTrackID ];
        [_tracks addObject:dbTrack];
    }
    if (willReloadTable) {
        //reload tableview
        [_tblPlaylistTracks reloadData];
    }
    
    if (_tracks.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        _searchBar.hidden = YES;
        if ([NowPlayingViewController sharedManager].playingTrack) {
            
            UIImage *btnPlayingImage = [UIImage customWithTintColor:kAppColor duration:1.5];
            
            UIBarButtonItem *barItemPlaying = [[UIBarButtonItem alloc]initWithImage:btnPlayingImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnPlayingDidTouch)];
            self.navigationItem.rightBarButtonItem = barItemPlaying;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    } else {
        _searchBar.hidden = NO;
        if ([NowPlayingViewController sharedManager].playingTrack) {
            
            UIImage *btnPlayingImage = [UIImage customWithTintColor:kAppColor duration:1.5];
            
            UIBarButtonItem *barItemPlaying = [[UIBarButtonItem alloc]initWithImage:btnPlayingImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnPlayingDidTouch)];
            self.navigationItem.rightBarButtonItems = @[_barItem,barItemPlaying];
        } else {
            self.navigationItem.rightBarButtonItem = _barItem;
            
        }
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
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [_searchBar endEditing:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([_searchBar.text isEqualToString:@""]) {
        [self reloadAllTracksWillReloadTableView:YES];
    } else {
        [_tracks removeAllObjects];
        //[_tblPlaylistTracks reloadData];
        for (PlaylistTrack *playlistTrack in _fetchedResultsController.fetchedObjects) {
            DBTrack *dbTrack = [DBTrack findFirstWithTrackID:playlistTrack.dbTrackID ];
            if ([[dbTrack.title lowercaseString] rangeOfString:[_searchBar.text lowercaseString]].location == 0 ) {
                [_tracks addObject:dbTrack];
            }
        }
        for (PlaylistTrack *playlistTrack in _fetchedResultsController.fetchedObjects) {
            DBTrack *dbTrack = [DBTrack findFirstWithTrackID:playlistTrack.dbTrackID ];
            if ([[dbTrack.title lowercaseString] rangeOfString:[_searchBar.text lowercaseString]].location != NSNotFound &&
                [[dbTrack.title lowercaseString] rangeOfString:[_searchBar.text lowercaseString]].location != 0
                ) {
                [_tracks addObject:dbTrack];
            }
        }
        [_tblPlaylistTracks reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [_searchBar endEditing:YES];
    _searchBar.text = @"";
    [self reloadAllTracksWillReloadTableView:YES];
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
    
    DBTrack *track = _tracks[indexPath.row];
    [cell displayDBTrack:track];
    
    cell.trackCellDelegate = self;
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBar endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NowPlayingViewController *nowPlayingViewController = [NowPlayingViewController sharedManager];
    Track *selectedTrack = [[Track alloc]initWithDBTrack:_tracks[indexPath.row]];
    nowPlayingViewController.trackList = [[NSMutableArray alloc]init];
    for (DBTrack *dbTrack in _tracks) {
        [nowPlayingViewController.trackList addObject:[[Track alloc]initWithDBTrack:dbTrack]];
    }
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


#pragma mark - Track Cell Delegate

- (void)buttonMoreDidTouch:(id)sender;
{
    TrackCell *cell = (TrackCell *)sender;
    NSIndexPath *indexPath =  [_tblPlaylistTracks indexPathForCell:cell];
    
    //show Action Sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add",@"Delete",nil];
    
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


#pragma mark - FetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tblPlaylistTracks beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:{
            NSInteger realIndex = [_fetchedResultsController.fetchedObjects indexOfObject:anObject];
            
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:0];
                
                [_tblPlaylistTracks insertRowsAtIndexPaths:@[realIndexPath]
                                          withRowAnimation:UITableViewRowAnimationLeft];
            }
            //[self reloadAllTracksWillReloadTableView:NO];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            [_tblPlaylistTracks deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            //[self reloadAllTracksWillReloadTableView:NO];
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            [self reloadAllTracksWillReloadTableView:YES];
            break;
        }
        case NSFetchedResultsChangeMove:{
            break;
        }
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self reloadAllTracksWillReloadTableView:NO];
    [_tblPlaylistTracks endUpdates];
}


#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == btnAddIndex) {
        AddToPlaylistViewController *addToPlaylistViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addToPlaylistID"];
        addToPlaylistViewController.track = [[Track alloc]initWithDBTrack:[_tracks objectAtIndex:actionSheet.tag]];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        [addToPlaylistViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:addToPlaylistViewController animated:NO];
    } else if (buttonIndex == btnDeleteIndex) {
        NSArray *playlistTracks = [PlaylistTrack MR_findAllSortedBy:@"createdAt" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"playlistIndex = %@",_selectedPlaylist.index]];
        PlaylistTrack *playlistTrackDelete = playlistTracks[actionSheet.tag];
        
        [playlistTrackDelete deletePlaylistTrack];
    }
    
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
