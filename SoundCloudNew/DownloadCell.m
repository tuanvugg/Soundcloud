//
//  DownloadCell.m
//  SoundCloudNew
//
//  Created by tuanhi on 4/10/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "DownloadCell.h"
#import <UIKit/UIKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

@implementation DownloadCell

- (void)awakeFromNib {

    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)btnCancelDidTap:(id)sender;
{
    [_downloadCellDelegate buttonCancelTap:self];
}
- (IBAction)btnPauseDidTap:(id)sender;
{
    [_downloadCellDelegate buttonPauseDidTap:self];
}
@end
