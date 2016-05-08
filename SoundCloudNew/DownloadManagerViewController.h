//
//  DownloaderViewController.h
//  VDownloader
//
//  Created by Muhammad Zeeshan on 2/13/14.
//  Copyright (c) 2014 Muhammad Zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZUtility.h"
#import "MainViewController.h"
#import "Playlist.h"
#import "Track.h"
#import "Constant.h"



extern NSString * const kDownloadKeyURL;
extern NSString * const kDownloadKeyStartTime;
extern NSString * const kDownloadKeyFileName;
extern NSString * const kDownloadKeyProgress;
extern NSString * const kDownloadKeyTask;
extern NSString * const kDownloadKeyStatus;
extern NSString * const kDownloadKeyDetails;
extern NSString * const kDownloadKeyResumeData;

extern NSString * const RequestStatusDownloading;
extern NSString * const RequestStatusPaused;
extern NSString * const RequestStatusFailed;




@protocol DownloadDelegate <NSObject>
@optional
/**A delegate method called each time whenever new download task is start downloading
 */
- (void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is cancelled by the user
 */
- (void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is finished successfully
 */
- (void)downloadRequestFinished:(NSString *)fileName;
@end

@interface DownloadManagerViewController :MainViewController
{
    
}
/**An array that holds the information about all downloading tasks.
 */
@property(nonatomic, strong) NSMutableArray *downloadingArray;
/**A table view for displaying details of on going download tasks.
 */
@property(nonatomic, weak) IBOutlet UITableView *bgDownloadTableView;
/**A session manager for background downloading.
 */
@property(nonatomic, strong) NSURLSession *sessionManager;
@property (nonatomic, weak) id<DownloadDelegate> delegate;
@property (nonatomic, strong) Playlist* downloadPlaylist;

- (NSURLSession *)backgroundSession;
/**A method for adding new download task.
 @param NSString* file name
 @param NSString* file url
 */

- (void)addDownloadTask:(Track*)downloadTrack;
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL;
/**A method for restoring any interrupted download tasks e.g user force quits the app or any network error occurred.
 */
- (void)populateOtherDownloadTasks;
@end
