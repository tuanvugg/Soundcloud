//
//  PlaylistViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "PlaylistViewController.h"
#import "Constant.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Playlist.h"
#import "PlaylistCell.h"
#import "NowPlayingViewController.h"
#import "PlaylistDetailViewController.h"
#import "UIImage+Custom.h"

@interface PlaylistViewController () <NSFetchedResultsControllerDelegate>

@property(nonatomic,strong) NSMutableArray *playlists;
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setup SearchBar
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_searchBar setTintColor:kAppColor];
    
    _tblPlaylists.tableFooterView = [[UIView alloc]init];
    
    _fetchedResultsController = [Playlist MR_fetchAllSortedBy:@"index"
                                                    ascending:NO
                                                withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]
                                                      groupBy:nil
                                                     delegate:self];
    [self reloadAllPlaylistsWillReloadTableView:YES];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar endEditing:YES];
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)reloadAllPlaylistsWillReloadTableView:(BOOL)willReloadTable;
{
    _playlists = [[NSMutableArray alloc]initWithArray:[Playlist MR_findAllSortedBy:@"index" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]]];
    if (willReloadTable) {
        [_tblPlaylists reloadData];
    }
    
}

- (void)btnDeleteDidTouchAtIndexPath:(PlaylistCell *)cell;
{
    [cell.cellPlaylist deletePlaylist];
}

- (void)btnRenameDidTouchAtIndexPath:(PlaylistCell *)cell;
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename Playlist"
                                                                   message:@"Enter a name for this playlist"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSString stringWithFormat:@"%@",cell.cellPlaylist.title];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        cell.cellPlaylist.title = alert.textFields[0].text;
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:save];
    
    [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        return _playlists.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellId = @"playlistCell";
        
        PlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PlaylistCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [cell displayBtnNewPlaylist];
        
        return cell;
    } else {
        static NSString *cellId = @"playlistCell";
        
        PlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"PlaylistCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [cell displayPlaylist:_playlists[indexPath.row]];

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
            [self btnDeleteDidTouchAtIndexPath:cell];
            return TRUE;
        }],
                              [MGSwipeButton buttonWithTitle:@"Rename" backgroundColor:[UIColor blueColor] callback:^BOOL(MGSwipeTableCell *sender) {
                                  [self btnRenameDidTouchAtIndexPath:cell];
                                  return TRUE;
                              }]];
        cell.rightSwipeSettings.transition = MGSwipeStateSwippingLeftToRight;
        
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    else {
        return 55;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [_searchBar endEditing:YES];
    if (indexPath.section == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Playlist"
                                                                       message:@"Enter a name for this playlist"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"";
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [Playlist createPlaylistWithTitle:alert.textFields[0].text];
            
        }];
        
        [alert addAction:cancel];
        [alert addAction:save];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        Playlist *selectedPlaylist = _playlists[indexPath.row];
        
        PlaylistDetailViewController *playlistDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistDetail"];
        playlistDetailViewController.selectedPlaylist = selectedPlaylist;
        
        [self.navigationController pushViewController:playlistDetailViewController animated:YES];
    }
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
        [self reloadAllPlaylistsWillReloadTableView:YES];
    } else {
        [_playlists removeAllObjects];
        [_tblPlaylists reloadData];
        
        NSArray *playlistData = [[NSMutableArray alloc]initWithArray:[Playlist MR_findAllSortedBy:@"index" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]]];
        
        for (Playlist *playlist in playlistData) {
            if ([[playlist.title lowercaseString] rangeOfString:[_searchBar.text lowercaseString]].location == 0 ) {
                [_playlists addObject:playlist];
            }
        }
        playlistData = [[NSMutableArray alloc]initWithArray:[Playlist MR_findAllSortedBy:@"title" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]]];
        for (Playlist *playlist in playlistData) {
            if ([[playlist.title lowercaseString] rangeOfString:[_searchBar.text lowercaseString]].location != 0 &&
                [[playlist.title lowercaseString] rangeOfString:[_searchBar.text lowercaseString]].location != NSNotFound) {
                [_playlists addObject:playlist];
            }
        }
        [_tblPlaylists reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [_searchBar endEditing:YES];
    _searchBar.text = @"";
    [self reloadAllPlaylistsWillReloadTableView:YES];
}

#pragma mark - FetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tblPlaylists beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:{
            NSInteger realIndex = [_fetchedResultsController.fetchedObjects indexOfObject:anObject];
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:1];
                
                [_tblPlaylists insertRowsAtIndexPaths:@[realIndexPath]
                                   withRowAnimation:UITableViewRowAnimationLeft];
            }
            break;
        }
        case NSFetchedResultsChangeDelete:{
            NSInteger realIndex = [_playlists indexOfObject:anObject];
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:1];
                
                [_tblPlaylists deleteRowsAtIndexPaths:@[realIndexPath]
                                          withRowAnimation:UITableViewRowAnimationRight];
                
            }
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            NSInteger realIndex = [_fetchedResultsController.fetchedObjects indexOfObject:anObject];
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:1];
                
                [_tblPlaylists reloadRowsAtIndexPaths:@[realIndexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
                
            }
            break;
        }
        case NSFetchedResultsChangeMove:{
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self reloadAllPlaylistsWillReloadTableView:NO];
    [_tblPlaylists endUpdates];
}
@end
