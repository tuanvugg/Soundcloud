//
//  DownloaderViewController.m
//  VDownloader
//
//  Created by Muhammad Zeeshan on 2/13/14.
//  Copyright (c) 2014 Muhammad Zeeshan. All rights reserved.
//

#import "DownloadManagerViewController.h"
#import "DownloadCell.h"
#import "AppDelegate.h"
#import "MZUtility.h"
#import "Constant.h"
#import "Track.h"
#import "PlaylistTrack.h"
#import <MagicalRecord/MagicalRecord.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

NSString * const kDownloadTrackInfo = @"downloadTrackInfo";
NSString * const kDownloadKeyURL = @"URL";
NSString * const kDownloadKeyStartTime = @"startTime";
NSString * const kDownloadKeyFileName = @"fileName";
NSString * const kDownloadKeyProgress = @"progress";
NSString * const kDownloadKeyTask = @"downloadTask";
NSString * const kDownloadKeyStatus = @"requestStatus";
NSString * const kDownloadKeyDetails = @"downloadDetails";
NSString * const kDownloadKeyResumeData = @"resumedata";

NSString * const RequestStatusDownloading = @"RequestStatusDownloading";
NSString * const RequestStatusPaused = @"RequestStatusPaused";
NSString * const RequestStatusFailed = @"RequestStatusFailed";

// Track Info




@interface DownloadManagerViewController () <NSURLSessionDelegate, UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,DownloadCellDelegate>
{
    NSIndexPath *selectedIndexPath;
    
    UIActionSheet *actionSheetRetry;
    UIActionSheet *actionSheetPause;
    UIActionSheet *actionSheetStart;
    UITabBarItem *tabbarItem;
}
@end

@implementation DownloadManagerViewController
@synthesize downloadingArray,bgDownloadTableView,sessionManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    tabbarItem = [[[[self tabBarController] tabBar] items]objectAtIndex:4];
   
    bgDownloadTableView.rowHeight = 100.0f;
    [super viewDidLoad];
    self.title = @"Download";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:kAppColor}];
    
	// Do any additional setup after loading the view.
    actionSheetRetry = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Retry",@"Delete", nil];
    actionSheetPause = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Pause",@"Delete", nil];
    actionSheetStart = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start",@"Delete", nil];
}


-(void)updateBadge
{
    if (downloadingArray.count !=0) {
        [tabbarItem setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)downloadingArray.count]];
    }else{
        tabbarItem.badgeValue = nil;
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - My Methods -
- (NSURLSession *)backgroundSession
{
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.iosDevelopment.VDownloader.SimpleBackgroundTransfer.BackgroundSession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}
- (NSArray *)tasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}
- (NSArray *)dataTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}
- (NSArray *)uploadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}
- (NSArray *)downloadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}
- (NSArray *)tasksForKeyPath:(NSString *)keyPath
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [sessionManager getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return tasks;
}
//Download Task With Track

- (void)addDownloadTask:(Track*)downloadTrack
{
    
//    NSLog(@"Track Titile %@",downloadTrack.title);
//    
//    NSMutableDictionary *trackInfo;
//    [trackInfo setObject:downloadTrack.title forKey:@"title"];
//    [trackInfo setObject:downloadTrack.userName forKey:@"userName"];
//    [trackInfo setObject:downloadTrack.trackID forKey:@"trackID"];
//    [trackInfo setObject:downloadTrack.artworkURL forKey:@"artworkURL"];

//    [downloadTrack setValuesForKeysWithDictionary:trackInfo];
    
    NSString *urlDownload = [NSString stringWithFormat:@"%@?client_id=%@",downloadTrack.streamURL,kSoundCloudAppID];
    NSURL *url = [NSURL URLWithString:urlDownload];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request];
    
    [downloadTask resume];

    
    
    NSMutableDictionary *downloadInfo = [NSMutableDictionary dictionary];
    

    
//    [downloadInfo setObject:trackInfo forKey:kDownloadTrackInfo];
    [downloadInfo setObject:urlDownload forKey:kDownloadKeyURL];
    [downloadInfo setObject:[NSString stringWithFormat:@"%@.mp3",downloadTrack.title] forKey:kDownloadKeyFileName];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:downloadInfo options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [downloadTask setTaskDescription:jsonString];
    
    [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
    [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
    [downloadInfo setObject:downloadTask forKey:kDownloadKeyTask];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downloadingArray.count inSection:0];
    [downloadingArray addObject:downloadInfo];
    
    [bgDownloadTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    if([self.delegate respondsToSelector:@selector(downloadRequestStarted:)])
        [self.delegate downloadRequestStarted:downloadTask];
}
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL
{
    NSURL *url = [NSURL URLWithString:fileURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request];
    
    [downloadTask resume];
    
    NSMutableDictionary *downloadInfo = [NSMutableDictionary dictionary];
    [downloadInfo setObject:fileURL forKey:kDownloadKeyURL];
    [downloadInfo setObject:fileName forKey:kDownloadKeyFileName];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:downloadInfo options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [downloadTask setTaskDescription:jsonString];
    
    [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
    [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
    [downloadInfo setObject:downloadTask forKey:kDownloadKeyTask];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downloadingArray.count inSection:0];
    [downloadingArray addObject:downloadInfo];
    
    [bgDownloadTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    if([self.delegate respondsToSelector:@selector(downloadRequestStarted:)])
        [self.delegate downloadRequestStarted:downloadTask];
}
- (void)populateOtherDownloadTasks
{
    NSArray *downloadTasks = [self downloadTasks];
    
    for(int i=0;i<downloadTasks.count;i++)
    {
        NSURLSessionDownloadTask *downloadTask = [downloadTasks objectAtIndex:i];
        
        NSError *error = nil;
        NSData *taskDescription = [downloadTask.taskDescription dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *downloadInfo = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
        
        if(error)
            NSLog(@"Error while retreiving json value: %@",error);
        
        [downloadInfo setObject:downloadTask forKey:kDownloadKeyTask];
        [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
        
        NSURLSessionTaskState taskState = downloadTask.state;
        if(taskState == NSURLSessionTaskStateRunning)
            [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
        else if(taskState == NSURLSessionTaskStateSuspended)
            [downloadInfo setObject:RequestStatusPaused forKey:kDownloadKeyStatus];
        else
            [downloadInfo setObject:RequestStatusFailed forKey:kDownloadKeyStatus];
        
        if(!downloadInfo)
        {
            [downloadTask cancel];
        }
        else
        {
            [self.downloadingArray addObject:downloadInfo];
        }
    }
}
/**Post local notification when all download tasks are finished
 */
- (void)presentNotificationForDownload:(NSString *)fileName
{
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState appCurrentState = [application applicationState];
    if(appCurrentState == UIApplicationStateBackground)
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"Downloading complete of %@",fileName];
        localNotification.alertAction = @"Background Transfer Download!";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
//        localNotification.applicationIconBadgeNumber = [application applicationIconBadgeNumber] + 1;
        localNotification.applicationIconBadgeNumber = [downloadingArray count];
        [application presentLocalNotificationNow:localNotification];
    }
}
#pragma mark - NSURLSession Delegates -
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    for(NSMutableDictionary *downloadDict in downloadingArray)
    {
        if([downloadTask isEqual:[downloadDict objectForKey:kDownloadKeyTask]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = (double)downloadTask.countOfBytesReceived/(double)downloadTask.countOfBytesExpectedToReceive;
                
                NSTimeInterval downloadTime = -1 * [[downloadDict objectForKey:kDownloadKeyStartTime] timeIntervalSinceNow];
                
                float speed = totalBytesWritten / downloadTime;
                
                NSInteger indexOfDownloadDict = [downloadingArray indexOfObject:downloadDict];
                NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:indexOfDownloadDict inSection:0];
                DownloadCell *cell = (DownloadCell *)[bgDownloadTableView cellForRowAtIndexPath:indexPathToRefresh];
                

    
                FAKFoundationIcons *minusIcon = [FAKFoundationIcons  pageDeleteIconWithSize:20.0f];
                FAKFoundationIcons *pauseIcon = [FAKFoundationIcons pauseIconWithSize:20.0f];
                UIImage *imgBtnCancel = [minusIcon imageWithSize:CGSizeMake(20, 20)];
                UIImage *imgBtnPause = [pauseIcon imageWithSize:CGSizeMake(20, 20)];
                [cell.btnCancel setImage:imgBtnCancel forState:UIControlStateNormal];
                [cell.btnPause setImage:imgBtnPause forState:UIControlStateNormal];
                
                
                [cell.progressDownload setProgress:progress];
                cell.progressDownload.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
                
                NSMutableString *remainingTimeStr = [[NSMutableString alloc] init];
                
                unsigned long long remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten;
                
                int remainingTime = (int)(remainingContentLength / speed);
                int hours = remainingTime / 3600;
                int minutes = (remainingTime - hours * 3600) / 60;
                int seconds = remainingTime - hours * 3600 - minutes * 60;
                
                if(hours>0)
                    [remainingTimeStr appendFormat:@"%d Hours ",hours];
                if(minutes>0)
                    [remainingTimeStr appendFormat:@"%d Min ",minutes];
                if(seconds>0)
                    [remainingTimeStr appendFormat:@"%d sec",seconds];
                
                NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                             [MZUtility calculateFileSizeInUnit:(unsigned long long)totalBytesExpectedToWrite],
                                             [MZUtility calculateUnit:(unsigned long long)totalBytesExpectedToWrite]];
                
                NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"Size: %@ Downloaded: %.2f %@ (%.2f%%)\nSpeed: %.2f %@/sec\n",fileSizeInUnits,
                                                    [MZUtility calculateFileSizeInUnit:(unsigned long long)totalBytesWritten],
                                                    [MZUtility calculateUnit:(unsigned long long)totalBytesWritten],progress*100,
                                                    [MZUtility calculateFileSizeInUnit:(unsigned long long) speed],
                                                    [MZUtility calculateUnit:(unsigned long long)speed]
                                                    ];
                
                if(progress == 1.0)
                    [detailLabelText appendFormat:@"Time Left: Please wait..."];
                else
                    [detailLabelText appendFormat:@"Time Left: %@",remainingTimeStr];
                
                [cell.lblDetails setText:detailLabelText];
                
                [downloadDict setObject:[NSString stringWithFormat:@"%f",progress] forKey:kDownloadKeyProgress];
                [downloadDict setObject:detailLabelText forKey:kDownloadKeyDetails];
            });
            break;
        }
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    for(NSMutableDictionary *downloadInfo in downloadingArray)
    {
        if([[downloadInfo objectForKey:kDownloadKeyTask] isEqual:downloadTask])
        {
            NSString *fileName = [downloadInfo objectForKey:kDownloadKeyFileName];
            NSString *destinationPath = [fileDest stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
            NSLog(@"directory Path = %@",destinationPath);
            _downloadPlaylist = [Playlist MR_findFirstByAttribute:@"title"
                                                        withValue:kTitlePlaylistDownload];
//            NSMutableDictionary *trackInfo = [[NSMutableDictionary alloc]init];
//            trackInfo = [downloadInfo objectForKey:kDownloadTrackInfo];
//            [trackInfo setObject:destinationPath forKey:@"streamURL"];
            Track *downloadedTrack;
//            downloadedTrack.title = [trackInfo objectForKey:@"title"];
//            downloadedTrack.userName = [trackInfo objectForKey:@"userName"];
//            downloadedTrack.trackID = [trackInfo objectForKey:@"trackID"];
//            downloadedTrack.duration = [trackInfo objectForKey:@"duration"];
//            downloadedTrack.artworkURL = [trackInfo objectForKey:@"artworkURL"];
//            downloadedTrack.playCount = [trackInfo objectForKey:@"playCount"];
//            downloadedTrack.streamURL = [trackInfo objectForKey:@"streamURL"];
            downloadedTrack.streamURL = destinationPath;
            downloadedTrack.title = fileName;
            
            
            
            DBTrack *dbTrack = [DBTrack createDBTrackWithTrack:downloadedTrack];
            [PlaylistTrack createPlaylistTrackWithPlaylist:_downloadPlaylist andDBTrack:dbTrack];
            
//            NSLog(@"track Info %@",trackInfo);

            
            if (location) {
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
                if (error)
                    [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
            }
            
            break;
        }
    }
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
    
    NSInteger errorReasonNum = [[error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] integerValue];
    
    NSLog(@"Directory :%@",[self applicationDocumentsDirectory]);
    if([error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] &&
       (errorReasonNum == NSURLErrorCancelledReasonUserForceQuitApplication ||
        errorReasonNum == NSURLErrorCancelledReasonBackgroundUpdatesDisabled))
    {
        NSString *taskInfo = task.taskDescription;
        
        NSError *error = nil;
        NSData *taskDescription = [taskInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *taskInfoDict = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
        
        if(error)
            NSLog(@"Error while retreiving json value: %@",error);
        
        NSString *fileName = [taskInfoDict objectForKey:kDownloadKeyFileName];
        NSString *fileURL = [taskInfoDict objectForKey:kDownloadKeyURL];
        
        NSMutableDictionary *downloadInfo = [[NSMutableDictionary alloc] init];
        [downloadInfo setObject:fileName forKey:kDownloadKeyFileName];
        [downloadInfo setObject:fileURL forKey:kDownloadKeyURL];
        
        NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if(resumeData)
            task = [sessionManager downloadTaskWithResumeData:resumeData];
        else
            task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:fileURL]];
        [task setTaskDescription:taskInfo];
        
        [downloadInfo setObject:task forKey:kDownloadKeyTask];
        
        [self.downloadingArray addObject:downloadInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bgDownloadTableView reloadData];
            [self dismissAllActionSeets];
        });
        return;
    }
    for(NSMutableDictionary *downloadInfo in downloadingArray)
    {
        if([[downloadInfo objectForKey:kDownloadKeyTask] isEqual:task])
        {
            NSInteger indexOfObject = [downloadingArray indexOfObject:downloadInfo];
            
            if(error)
            {
                if(error.code != NSURLErrorCancelled)
                {
                    NSString *taskInfo = task.taskDescription;
                    
                    NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                    if(resumeData)
                        task = [sessionManager downloadTaskWithResumeData:resumeData];
                    else
                        task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:[downloadInfo objectForKey:kDownloadKeyURL]]];
                    [task setTaskDescription:taskInfo];
                    
                    [downloadInfo setObject:RequestStatusFailed forKey:kDownloadKeyStatus];
                    [downloadInfo setObject:(NSURLSessionDownloadTask *)task forKey:kDownloadKeyTask];
                    
                    [downloadingArray replaceObjectAtIndex:indexOfObject withObject:downloadInfo];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
                        [self.bgDownloadTableView reloadData];
                        [self dismissAllActionSeets];
                        
                    });
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *fileName = [[downloadInfo objectForKey:kDownloadKeyFileName] copy];
                    
                    [self presentNotificationForDownload:[downloadInfo objectForKey:kDownloadKeyFileName]];
                    
                    [downloadingArray removeObjectAtIndex:indexOfObject];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfObject inSection:0];
                    [bgDownloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    if([self.delegate respondsToSelector:@selector(downloadRequestFinished:)])
                    [self.delegate downloadRequestFinished:fileName];
                     [self updateBadge];
                    
                    [self dismissAllActionSeets];
                });
            }
            break;
        }
    }
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");
}
#pragma mark - UITableView Delegates and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return downloadingArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DownloadingCell";
    
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"DownloadCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.downloadCellDelegate = self;
    [cell.progressDownload hidePopUpViewAnimated:YES];

    
    [self updateCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}
- (void)updateCell:(DownloadCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *downloadInfoDict = [downloadingArray objectAtIndex:indexPath.row];
    
    NSString *fileName = [downloadInfoDict objectForKey:kDownloadKeyFileName];
    
    [cell.lblTitle setText:[NSString stringWithFormat:@"%@",fileName]];
    [cell.detailTextLabel setText:[downloadInfoDict objectForKey:kDownloadKeyDetails]];
    [cell.progressDownload setProgress:[[downloadInfoDict objectForKey:kDownloadKeyProgress] floatValue]];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = [indexPath copy];
    
    NSMutableDictionary *downloadInfoDict = [downloadingArray objectAtIndex:indexPath.row];
    
    if([[downloadInfoDict objectForKey:kDownloadKeyStatus] isEqualToString:RequestStatusPaused])
        [actionSheetStart showFromTabBar:self.tabBarController.tabBar];
    else if([[downloadInfoDict objectForKey:kDownloadKeyStatus] isEqualToString:RequestStatusDownloading])
        [actionSheetPause showFromTabBar:self.tabBarController.tabBar];
    else
        [actionSheetRetry showFromTabBar:self.tabBarController.tabBar];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UIActionSheet Delegates -
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
        [self pauseOrRetryButtonTappedOnActionSheet];
    else if(buttonIndex == 1)
        [self cancelButtonTappedOnActionSheet];
    [self updateBadge];
}
-(void)buttonPauseDidTap:(id)sender
{
    DownloadCell *downloadCell = (DownloadCell*)sender;
    
    NSIndexPath *indexPath = [bgDownloadTableView indexPathForCell:downloadCell];
    NSMutableDictionary *downloadInfo = [downloadingArray objectAtIndex:indexPath.row];
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kDownloadKeyTask];
    NSString *downloadingStatus = [downloadInfo objectForKey:kDownloadKeyStatus];
    
    if([downloadingStatus isEqualToString:RequestStatusDownloading])
    {
        [downloadTask suspend];
        [downloadInfo setObject:RequestStatusPaused forKey:kDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
        
        FAKFoundationIcons *loopIcon = [FAKFoundationIcons loopIconWithSize:20.0f];
        UIImage *imgBtnRetry = [loopIcon imageWithSize:CGSizeMake(20, 20)];
        [downloadCell.btnPause setImage:imgBtnRetry forState:UIControlStateNormal];
        
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:downloadCell forRowAtIndexPath:indexPath];
    }
    else if([downloadingStatus isEqualToString:RequestStatusPaused])
    {
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
        
        
        FAKFoundationIcons *pauseIcon = [FAKFoundationIcons pauseIconWithSize:20.0f];
        UIImage *imgBtnPause = [pauseIcon imageWithSize:CGSizeMake(20, 20)];
        [downloadCell.btnPause setImage:imgBtnPause forState:UIControlStateNormal];
        
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:downloadCell forRowAtIndexPath:indexPath];
    }
    else
    {
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
        [downloadInfo setObject:downloadTask forKey:kDownloadKeyTask];
        
        FAKFoundationIcons *pauseIcon = [FAKFoundationIcons pauseIconWithSize:20.0f];
        UIImage *imgBtnPause = [pauseIcon imageWithSize:CGSizeMake(20, 20)];
        [downloadCell.btnPause setImage:imgBtnPause forState:UIControlStateNormal];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:downloadCell forRowAtIndexPath:indexPath];
    }

}

-(void)buttonCancelTap:(id)sender
{
    
    NSInteger badgeValue = [tabbarItem.badgeValue integerValue] -1;
    if (badgeValue >0) {
        tabbarItem.badgeValue =[NSString stringWithFormat:@"%ld",(long)badgeValue];
    }else
    {
        tabbarItem.badgeValue = nil;
    }
    
    NSLog(@"COUNT %lu",(unsigned long)downloadingArray.count);
    DownloadCell *downloadCell = (DownloadCell*)sender;
    
    NSIndexPath *indexPath = [bgDownloadTableView indexPathForCell:downloadCell];
    
    NSMutableDictionary *downloadInfo = [downloadingArray objectAtIndex:indexPath.row];
    
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kDownloadKeyTask];
    
    [downloadTask cancel];
    
    [downloadingArray removeObjectAtIndex:indexPath.row];
    [bgDownloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    if([self.delegate respondsToSelector:@selector(downloadRequestCanceled:)])
        [self.delegate downloadRequestCanceled:downloadTask];
    
}
- (void)dismissAllActionSeets
{
    [actionSheetPause dismissWithClickedButtonIndex:2 animated:YES];
    [actionSheetRetry dismissWithClickedButtonIndex:2 animated:YES];
    [actionSheetStart dismissWithClickedButtonIndex:2 animated:YES];
}
#pragma mark - DownloadingCell Delegate -
- (IBAction)cancelButtonTappedOnActionSheet
{
    
    NSInteger badgeValue = [tabbarItem.badgeValue integerValue] -1;
    if (badgeValue >0) {
        tabbarItem.badgeValue =[NSString stringWithFormat:@"%ld",(long)badgeValue];
    }else
    {
        tabbarItem.badgeValue = nil;
    }
    NSIndexPath *indexPath = selectedIndexPath;
    
    NSMutableDictionary *downloadInfo = [downloadingArray objectAtIndex:indexPath.row];
    
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kDownloadKeyTask];
    
    [downloadTask cancel];
    
    [downloadingArray removeObjectAtIndex:indexPath.row];
    [bgDownloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    if([self.delegate respondsToSelector:@selector(downloadRequestCanceled:)])
        [self.delegate downloadRequestCanceled:downloadTask];
}
- (IBAction)pauseOrRetryButtonTappedOnActionSheet
{
    NSIndexPath *indexPath = selectedIndexPath;
    DownloadCell *cell = (DownloadCell *)[bgDownloadTableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary *downloadInfo = [downloadingArray objectAtIndex:indexPath.row];
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kDownloadKeyTask];
    NSString *downloadingStatus = [downloadInfo objectForKey:kDownloadKeyStatus];
    
    if([downloadingStatus isEqualToString:RequestStatusDownloading])
    {
        [downloadTask suspend];
        [downloadInfo setObject:RequestStatusPaused forKey:kDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:cell forRowAtIndexPath:indexPath];
    }
    else if([downloadingStatus isEqualToString:RequestStatusPaused])
    {
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:cell forRowAtIndexPath:indexPath];
    }
    else
    {
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kDownloadKeyStartTime];
        [downloadInfo setObject:downloadTask forKey:kDownloadKeyTask];
        
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:downloadInfo];
        [self updateCell:cell forRowAtIndexPath:indexPath];
    }
}
#pragma mark - UIInterfaceOrientations -
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}
@end
