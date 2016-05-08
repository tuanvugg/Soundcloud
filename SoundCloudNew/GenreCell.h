//
//  GenreCell.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/27/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvGenre;
@property (weak, nonatomic) IBOutlet UILabel *lblGenreTitle;

- (void)displayGenre:(Genre *)genre;

@end
