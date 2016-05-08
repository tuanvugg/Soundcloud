//
//  PlaylistCell.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/28/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import <MGSwipeTableCell.h>

@interface PlaylistCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *imvArtwork;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTrackNumber;
@property (nonatomic, weak) Playlist *cellPlaylist;

- (void)displayPlaylist:(Playlist *)playlist;

- (void)displayBtnNewPlaylist;

@end
