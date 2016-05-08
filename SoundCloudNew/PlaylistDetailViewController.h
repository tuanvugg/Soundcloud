//
//  PlaylistDetailViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/30/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "Playlist.h"

@interface PlaylistDetailViewController : MainViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) Playlist *selectedPlaylist;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblPlaylistTracks;

@end
