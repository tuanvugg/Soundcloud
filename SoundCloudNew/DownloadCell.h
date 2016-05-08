//
//  DownloadCell.h
//  SoundCloudNew
//
//  Created by tuanhi on 4/10/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASProgressPopUpView.h"

@protocol DownloadCellDelegate <NSObject>

- (void)buttonPauseDidTap:(id)sender;
- (void)buttonCancelTap:(id)sender;

@end

@interface DownloadCell : UITableViewCell


@property (weak, nonatomic) id<DownloadCellDelegate> downloadCellDelegate;

@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressDownload;

@property(nonatomic, weak) IBOutlet UILabel *lblTitle;
@property(nonatomic, weak) IBOutlet UILabel *lblDetails;

@property(nonatomic, weak) IBOutlet UIButton *btnPause;
@property(nonatomic, weak) IBOutlet UIButton *btnCancel;

- (IBAction)btnCancelDidTap:(id)sender;
- (IBAction)btnPauseDidTap:(id)sender;



@end
