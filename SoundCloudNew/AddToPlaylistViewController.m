//
//  AddToPlaylistViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/30/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "AddToPlaylistViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Playlist.h"
#import "PlaylistCell.h"
#import "Constant.h"
#import "PlaylistTrack.h"

@interface AddToPlaylistViewController () <NSFetchedResultsControllerDelegate>

@property(nonatomic,strong) NSMutableArray *playlists;
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,strong) UIBarButtonItem *barItem;
@property(nonatomic,strong) Playlist *selectedPlaylist;

@end

@implementation AddToPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Add To Playlist";
    
    _tblPlaylists.tableFooterView = [[UIView alloc]init];
    
    
    [self.navigationItem setHidesBackButton:TRUE];
    _barItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(btnDoneAllDidTouch)];
    self.navigationItem.rightBarButtonItem = _barItem;
    
    _barItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(btnCancelAllDidTouch)];
    self.navigationItem.leftBarButtonItem = _barItem;
    
    
    
    _fetchedResultsController = [Playlist MR_fetchAllSortedBy:@"index"
                                                    ascending:NO
                                                withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]
                                                      groupBy:nil
                                                     delegate:self];
    [self reloadAllPlaylistsWillReloadTableView:YES];
    
    if (_playlists.count != 0) {
        _selectedPlaylist = [_playlists objectAtIndex:0];
    }
    
}

- (void)btnDoneAllDidTouch;
{
    
    DBTrack *dbTrack = [DBTrack createDBTrackWithTrack:_track];
    [PlaylistTrack createPlaylistTrackWithPlaylist:_selectedPlaylist andDBTrack:dbTrack];

    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)btnCancelAllDidTouch;
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)reloadAllPlaylistsWillReloadTableView:(BOOL)willReloadTable;
{
    _playlists = [[NSMutableArray alloc]initWithArray:[Playlist MR_findAllSortedBy:@"index" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"index != %@",kHistoryPlaylistIndex]]];
    if (willReloadTable) {
        [_tblPlaylists reloadData];
    }
    if (_playlists.count == 1) {
        _selectedPlaylist = [_playlists objectAtIndex:0];
    }
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
        if (_selectedPlaylist && [_playlists indexOfObject:_selectedPlaylist] == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0){
        return nil;
    }else{
        return @"Playlists";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:kAppColor];
    
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
        _selectedPlaylist = _playlists[indexPath.row];
        [self reloadAllPlaylistsWillReloadTableView:YES];
    }
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
            //NSLog(@"update");
            NSInteger realIndex = [_fetchedResultsController.fetchedObjects indexOfObject:anObject];
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:1];
                
                [_tblPlaylists reloadRowsAtIndexPaths:@[realIndexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
                
            }
            break;
        }
        case NSFetchedResultsChangeMove:{
            //NSLog(@"move");
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self reloadAllPlaylistsWillReloadTableView:NO];
    [_tblPlaylists endUpdates];
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
