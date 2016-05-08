//
//  GenresViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "GenresViewController.h"
#import "Constant.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Genre.h"
#import "DBTrack.h"
#import "GenreCell.h"
#import "SoundCloudAPI.h"
#import "GenreDetailViewController.h"
#import <SVPullToRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NowPlayingViewController.h"
#import "UIImage+Custom.h"

@interface GenresViewController () <NSFetchedResultsControllerDelegate>

@property(nonatomic,strong) NSMutableArray *genres;

@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation GenresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup tableview
    _tblGenres.tableFooterView = [[UIView alloc]init];
    _tblGenres.rowHeight = 70.0f;
    
    //setup FetchedResultsController
    _fetchedResultsController = [Genre MR_fetchAllSortedBy:@"index"
                                                  ascending:YES
                                              withPredicate:nil
                                                    groupBy:nil
                                                   delegate:self];
    
    _genres = [[NSMutableArray alloc]initWithArray:_fetchedResultsController.fetchedObjects];
    [_tblGenres addInfiniteScrollingWithActionHandler:^{
        if (_genres.count != 0) {
            _tblGenres.infiniteScrollingView.hidden = YES;
        }
    }];
    
    [self loadTracksInGenresIfItsNotFirstTimeLaunch];
    
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

- (void)loadTracksWithGenre:(Genre *)genre;
{
        [sSoundCloudAPI exploreTracksWithGenreCode:genre.code offset:kSoundCloudExploreDefaultOffset completionBlock:^(NSArray *tracks) {
            
            //get genre artwork
            if (![tracks[0][@"artwork_url"] isKindOfClass:[NSNull class]]) {
                Genre *dataGenre = [Genre MR_findFirstByAttribute:@"index" withValue:genre.index];
                dataGenre.artworkURL = tracks[0][@"artwork_url"];
            }
            
            
            //push tracks to database
            [DBTrack deleteAllDBTrackWithGenreIndex:genre.index];
            
            for (NSDictionary *jsonDict in tracks) {
                [DBTrack creatDBTrackWithJsonDict:jsonDict andGenreIndex:genre.index];
            }
            
            
            
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
                if (contextDidSave) {
                    NSLog(@"Data in default context SAVED");
                }
                if (error) {
                    NSLog(@"Data in default context ERROR %@", error);
                }
            }];
        }];
}

- (void)loadTracksInGenresIfItsNotFirstTimeLaunch;
{
    if (_genres.count > 0) {
        
        for (Genre *genre in _genres) {

            [self loadTracksWithGenre:genre];
        }
        
    } else {
        [_tblGenres triggerInfiniteScrolling];
    }
}
//#pragma mark - DZEmptyDataSet DataSource
//
//- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
//{
//    return [UIImage imageNamed:kAppLoadingImage];
//}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _genres.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellId = @"genreCell";
    
    GenreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"GenreCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Genre *genre = _genres[indexPath.row];
    [cell displayGenre:genre];
    
    return cell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Genre *selectedGenre = _genres[indexPath.row];
    
    GenreDetailViewController *genreDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"genreDetail"];
    genreDetailViewController.selectedGenre = selectedGenre;
    
    [self.navigationController pushViewController:genreDetailViewController animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tblGenres beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //_genres = [[NSMutableArray alloc]initWithArray:_fetcherResultsController.fetchedObjects];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            
            [self loadTracksWithGenre:anObject];
            
            NSUInteger realIndex = [_fetchedResultsController.fetchedObjects indexOfObject:anObject];
        
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:0];
                
                [_tblGenres insertRowsAtIndexPaths:@[realIndexPath]
                                   withRowAnimation:UITableViewRowAnimationLeft];
            }
            
            _tblGenres.infiniteScrollingView.hidden = YES;
            
        }
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            
            NSInteger realIndex = [_genres indexOfObject:anObject];
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:0];
                
                [_tblGenres deleteRowsAtIndexPaths:@[realIndexPath]
                                          withRowAnimation:UITableViewRowAnimationRight];
            }
            
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            NSUInteger realIndex = [_genres indexOfObject:anObject];
            
            if (realIndex != NSNotFound) {
                NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:realIndex inSection:0];
                
                [_tblGenres reloadRowsAtIndexPaths:@[realIndexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
                
            }
            
        }
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    _genres = [NSMutableArray arrayWithArray:[Genre MR_findAllSortedBy:@"index" ascending:YES]];
    [_tblGenres endUpdates];
}

@end
