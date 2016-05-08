//
//  CommonUtils.m
//
//

#include <sys/xattr.h>

#import "CommonUtils.h"
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"


#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <CommonCrypto/CommonDigest.h>



CGAffineTransform aspectFit(CGRect innerRect, CGRect outerRect) {
	CGFloat scaleFactor = MIN(outerRect.size.width/innerRect.size.width, outerRect.size.height/innerRect.size.height);
	CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
	CGRect scaledInnerRect = CGRectApplyAffineTransform(innerRect, scale);
	CGAffineTransform translation =
	CGAffineTransformMakeTranslation((outerRect.size.width - scaledInnerRect.size.width) / 2 - scaledInnerRect.origin.x,
									 (outerRect.size.height - scaledInnerRect.size.height) / 2 - scaledInnerRect.origin.y);
	return CGAffineTransformConcat(scale, translation);
}


@implementation NSString(reverseString)
-(NSString *) reverseString;
{
    NSMutableString *reversedStr;
    NSUInteger len = [self length];
    
    // Auto released string
    reversedStr = [NSMutableString stringWithCapacity:len];
    
    // Probably woefully inefficient...
    while (len > 0)
        [reversedStr appendString:
         [NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
    
    return reversedStr;
}


@end

@implementation UIImage (scale)
-(UIImage*)scaleToSize:(CGSize)size ;
{
	// Create a bitmap graphics context
	// This will also set it as the current context
	UIGraphicsBeginImageContext(size);
	
	// Draw the scaled image in the current context
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	
	// Create a new image from current context
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// Pop the current context from the stack
	UIGraphicsEndImageContext();
	
	// Return our new scaled image
	return scaledImage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox;
    
    if (!(degrees == 180.0 || degrees == 360.0 || degrees == 0.0))
        rotatedViewBox= [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    else
        rotatedViewBox= [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.height, self.size.width)];
    
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
//    [rotatedViewBox release];
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage *)scaleToMaxWidth:(float)maxWidth
                   maxHeight:(float) maxHeight
{
	if(self != nil)
	{
		CGImageRef imgRef = self.CGImage;
		CGFloat width = CGImageGetWidth(imgRef);
		CGFloat height = CGImageGetHeight(imgRef);
		UIImageOrientation    originalOrientation = self.imageOrientation;
        switch (originalOrientation)
		{
			case UIImageOrientationUp:
			{
			}
				break;
			case UIImageOrientationDown:
			{
			}
				break;
			case UIImageOrientationLeft:
			{
				height = CGImageGetWidth(imgRef);
				width = CGImageGetHeight(imgRef);
			}
				break;
			case UIImageOrientationRight:
			{
				height = CGImageGetWidth(imgRef);
				width = CGImageGetHeight(imgRef);
			}
				break;
			case UIImageOrientationUpMirrored:
			{
			}
				break;
			case UIImageOrientationDownMirrored:
			{
			}
				break;
			case UIImageOrientationLeftMirrored:
			{
			}
				break;
			case UIImageOrientationRightMirrored:
			{
			}
				break;
			default:
			{
			}
				break;
		}
		CGRect bounds = CGRectMake(0, 0, width, height);
		
		CGFloat ratio = width/height;
		CGFloat maxRatio = maxWidth/maxHeight;
		
		if(ratio > maxRatio)
		{
			bounds.size.width = maxWidth;
			bounds.size.height = bounds.size.width / ratio;
		}
		else
		{
			bounds.size.height = maxHeight;
			bounds.size.width = bounds.size.height * ratio;
		}
		
		//NSLog(@"after resize:%f,%f:",bounds.size.width,bounds.size.height);
		return [self scaleToSize:bounds.size];
	}
	return nil;
}


+ (UIImage *)captureImageFromView:(UIView *)view inFrame:(CGRect )captureFrame;
{
    UIImage *screenImage = nil;
    if (view == nil || CGRectIsNull(captureFrame)) {
        return screenImage;
    }
    
    CALayer *layer;
    layer = view.layer;
    
    //    layer.masksToBounds = YES;
    //    layer.cornerRadius = cornerRadius;
    
    double scale = [[UIScreen mainScreen] scale];
    
    //    CGSize captureSize = CGSizeMake(captureFrame.size.width * scale, captureFrame.size.height * scale);
    //    UIGraphicsBeginImageContext(captureSize);
    
    UIGraphicsBeginImageContextWithOptions(captureFrame.size, YES, scale);
    //    CGContextRef currentRef = UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(currentRef, -captureFrame.origin.x, -captureFrame.origin.y);
    //    CGContextClipToRect (currentRef, captureFrame);
    
    //    layer.contentsScale = scale;
    //    NSLog(@"contentsScale: %f", layer.contentsScale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"image size FRAME: %f, %f", screenImage.size.width, screenImage.size.height);
    
    return screenImage;
    
}


+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
{
    CGSize screenSize = [[UIScreen mainScreen]currentMode].size;
    int kMaxResolution = screenSize.height; // self.view.bounds.size.width; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage *)scaleAndRotateImage;
{
    return [UIImage scaleAndRotateImage:self];
}


+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*) roundCorneredRadius:(CGFloat) r {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, self.size}
                                cornerRadius:r] addClip];
    [self drawInRect:(CGRect){CGPointZero, self.size}];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end

#define RECT_TAG 1421
#define SPIN_TAG 4516

@implementation CommonUtils

#pragma File handler

+ (UIImage*)loadLocalImage:(NSString*)fileName{
    //TODO
    return [UIImage imageWithContentsOfFile:fileName];
}

/*
 set the document files attribute to marked "do not backup"
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


+ (NSString *)pathForSourceFile:(NSString *)file inDirectory:(NSString *)directory skipICloudBackup:(BOOL)skipBackup
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
	
	NSString *path = nil;
	if(directory == nil)
	{
		path = [documentsDirectory stringByAppendingPathComponent:file];
	}
	else
	{
		// if folder not exist, it will be created
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:directory];
		
		// create particular directory
		BOOL success = [fileManager createDirectoryAtPath:directoryPath
							  withIntermediateDirectories:YES
											   attributes:nil
													error:NULL];
		
		if(success)
		{
			path = [directoryPath stringByAppendingPathComponent:file];
		}
	}
    
    if (skipBackup) {
        // Set do not backup attribute to file
        if ([CommonUtils isIOS5O1rGreater]) {
            BOOL success = [self addSkipBackupAttributeToItemAtURL:path];
            if (success)
                NSLog(@"Marked %@", path);
            else
                NSLog(@"Can't marked %@", path);
        }
    }
    
	return path;
}

+ (NSString *)pathForSourceFile:(NSString *)file inDirectory:(NSString *)directory
{
	return [CommonUtils pathForSourceFile:file inDirectory:directory skipICloudBackup:FALSE];
}



+ (NSString *)pathLibraryForSourceFile:(NSString *)file inDirectory:(NSString *)directory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libDirectory = [paths objectAtIndex:0]; // Get Library directory
	
	NSString *path = nil;
	if(directory == nil)
	{
		path = [libDirectory stringByAppendingPathComponent:file];
	}
	else
	{
		// if folder not exist, it will be created
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *directoryPath = [libDirectory stringByAppendingPathComponent:directory];
		
		// create particular directory
		BOOL success = [fileManager createDirectoryAtPath:directoryPath
							  withIntermediateDirectories:YES
											   attributes:nil
													error:NULL];
		
		if(success)
		{
			path = [directoryPath stringByAppendingPathComponent:file];
		}
	}
	
	return path;
}

+ (NSString *)pathCacheForSourceFile:(NSString *)file inDirectory:(NSString *)directory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0]; // Get Library directory
	
	NSString *path = nil;
	if(directory == nil)
	{
		path = [cacheDirectory stringByAppendingPathComponent:file];
	}
	else
	{
		// if folder not exist, it will be created
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *directoryPath = [cacheDirectory stringByAppendingPathComponent:directory];
		
		// create particular directory
		BOOL success = [fileManager createDirectoryAtPath:directoryPath
							  withIntermediateDirectories:YES
											   attributes:nil
													error:NULL];
		
		if(success)
		{
			path = [directoryPath stringByAppendingPathComponent:file];
		}
	}
	
	return path;
}

+ (NSString *)pathTmpForSourceFile:(NSString *)file inDirectory:(NSString *)directory
{
    //	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory(), NSUserDomainMask, YES);
	NSString *tempDirectory = NSTemporaryDirectory();// [paths objectAtIndex:0]; // Get Library directory
	
	NSString *path = nil;
	if(directory == nil)
	{
		path = [tempDirectory stringByAppendingPathComponent:file];
	}
	else
	{
		// if folder not exist, it will be created
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *directoryPath = [tempDirectory stringByAppendingPathComponent:directory];
		
		// create particular directory
		BOOL success = [fileManager createDirectoryAtPath:directoryPath
							  withIntermediateDirectories:YES
											   attributes:nil
													error:NULL];
		
		if(success)
		{
			path = [directoryPath stringByAppendingPathComponent:file];
		}
	}
	
	return path;
}

+ (void)cleanTempFolder;
{
    NSLog(@"did CALL cleanTempFolder");
    //delete tmp folder
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory(), NSUserDomainMask, YES);
	NSString *tempDirectory = NSTemporaryDirectory(); // [paths objectAtIndex:0]; // Get tmp directory
    if ([fileMgr fileExistsAtPath:tempDirectory isDirectory:nil]) {
        NSArray *arrContent = [fileMgr contentsOfDirectoryAtPath:tempDirectory error:nil];
        if (arrContent && [arrContent count] > 0) {
            for (int i = 0; i < [arrContent count]; i++) {
                NSString *filePath = [arrContent objectAtIndex:i];
                filePath = [tempDirectory stringByAppendingPathComponent:filePath];
                NSLog(@"remove file: %@", filePath);
                //                filePath = [CommonUtils pathForSourceFile:filePath inDirectory:kTempFolderPreview];
                [fileMgr removeItemAtPath:filePath error:nil];
            }
        }
    }
}


+ (NSString *)fullPathFromFile:(NSString *)path
{
	if(path)
	{
		NSArray *components = [path componentsSeparatedByString:@"."];
		
		if([components count] > 1)
		{
			NSString *resourcePath =
			[[NSBundle mainBundle] pathForResource:[components objectAtIndex:0]
											ofType:[components objectAtIndex:1]];
			
			return resourcePath;
		}
	}
	return nil;
}

+ (NSString *)bundlePathForDirectory:(NSString *)dir;
{
    NSString *resourcePath = nil;
    
    if(dir != nil)
    {
        resourcePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:dir];
    }
    
	return resourcePath;
    
}

+ (NSString *)bundlePathForFile:(NSString *)file inDirectory:(NSString *)dir;
{
    NSString *resourcePath = nil;
	NSArray *components = [file componentsSeparatedByString:@"."];
    
    if([components count] > 1)
    {
        if(dir == nil)
        {
            resourcePath = [[NSBundle mainBundle] pathForResource:[components objectAtIndex:0]
                                                           ofType:[components objectAtIndex:1]];
        } else {
            NSArray *components = [file componentsSeparatedByString:@"."];
            
            if([components count] > 1)
            {
                resourcePath = [[NSBundle mainBundle] pathForResource:[components objectAtIndex:0]
                                                               ofType:[components objectAtIndex:1]
                                                          inDirectory:dir];
            }
        }
    }
    
	return resourcePath;
    
}



#pragma Custom methods
+ (void) openURLExternalHandlerForLink: (NSString *) urlLink;
{
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlLink]];
    
}

+ (BOOL) canOpenLink: (NSString *) urlLink;
{
    
    return [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlLink]];
    
}


#pragma App settings plist handler
+ (void) copyFilePlistIfNeccessaryForFileName: (NSString *) filename withFileType:(NSString *)fileType;
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@", filename,fileType]]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:filename ofType:fileType]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
}



#pragma -
#pragma Alertview

// Method used to show alert view with Title, message content and cancel button title
+ (void) showAlertViewWithTitle: (NSString *) title
                        message:(NSString*)msg
              cancelButtonTitle:(NSString*)cancelTitle;
{
	
    UIAlertView *alertView = [[UIAlertView alloc]
                               initWithTitle:title
                               message:msg
                               delegate:self
                               cancelButtonTitle:cancelTitle
                               otherButtonTitles:nil];
    [alertView show];
}

// Method used to show alert view with Title, message content and cancel button title
+ (void) showAlertViewWithTitle: (NSString *) title
                        message:(NSString*)msg
              cancelButtonTitle:(NSString*)cancelTitle
              otherButtonTitles: (NSString *) otherButtonTitles, ...
{
    // traditional alertview
    
    UIAlertView *alertView = [[UIAlertView alloc]  init];
    
    alertView.title = title;
    alertView.message = msg;
    alertView.delegate = self;
    
    if (cancelTitle != nil) {
        [alertView addButtonWithTitle:cancelTitle];
        alertView.cancelButtonIndex = 0;
    }
    
    if (otherButtonTitles != nil) {
        [alertView addButtonWithTitle: otherButtonTitles ];
        va_list args;
        va_start(args, otherButtonTitles);
        
        id arg;
        while ( nil != ( arg = va_arg( args, id ) ) )
        {
            if ( ![arg isKindOfClass: [NSString class] ] )
                break;
            
            [alertView addButtonWithTitle: (NSString*)arg ];
        }
        
    }
    
    [alertView show];
}

// Method used to show alert view with Title, message content and cancel button title
+ (void) showAlertViewWithTag: (NSInteger) tag
                     delegate:(id) delegate
                    withTitle: (NSString *) title
                      message:(NSString*)msg
            cancelButtonTitle:(NSString*)cancelTitle
            otherButtonTitles: (NSString *) otherButtonTitles, ... ;
{
    // traditional alertview
    UIAlertView *alertView = [[UIAlertView alloc]  init];
    
    alertView.title = title;
    alertView.message = msg;
    alertView.delegate = delegate;
    alertView.tag = tag;
    
    if (cancelTitle != nil) {
        [alertView addButtonWithTitle:cancelTitle];
        alertView.cancelButtonIndex = 0;
    }
    
    if (otherButtonTitles != nil) {
        [alertView addButtonWithTitle: otherButtonTitles ];
        
        va_list args;
        va_start(args, otherButtonTitles);
        id arg;
        while ( nil != ( arg = va_arg( args, id ) ) )
        {
            if ( ![arg isKindOfClass: [NSString class] ] )
                break;
            
            [alertView addButtonWithTitle: (NSString*)arg ];
        }
        
    }
    
    [alertView show];
    
}


// Function to check if device support multitasking
// Return: TRUE if device supports multitasking, otherwise return NO
+ (BOOL) isDeviceSupportMultitasking;
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
        backgroundSupported = device.multitaskingSupported;
    }
    
    //NSLog(@"support multitasking: %d ", backgroundSupported);
    return backgroundSupported;
}

+ (BOOL) isIOS5OrGreater;
{
    /* [[UIDevice currentDevice] systemVersion] returns "4.0", "3.1.3" and so on. */
    NSString* ver = [[UIDevice currentDevice] systemVersion];
    //    NSLog(@"Check ios410 %@",ver);
    /* I assume that the default iOS version will be 4.0, that is why I set this to 4.0 */
    float version = 5.0;
    
    if ([ver length]>=3)
    {
        /*
         The version string has the format major.minor.revision (eg. "3.1.3").
         I am not interested in the revision part of the version string, so I can do this.
         It will return the float value for "3.1", because substringToIndex is called first.
         */
        version = [[ver substringToIndex:3] floatValue];
    }
    return (version >= 5.0);
}

+ (BOOL) isIOS5O1rGreater;
{
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0.1");
}

+ (BOOL) isIOS51rGreater;
{
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1");
}


#pragma Network indicator show/hide animation
// Method used to show network indicator (top bar of device) animating while loading from server
+ (void) showNetworkIndicator;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// Method used to stop network indicator (top bar of device) animating after data is loaded successuflly
+ (void) hideNetworkIndicator;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// start indicator animation with black screen
// Edited by DatNT 07/05/2011
// Purpose: add autosizing and contentMode, to auto resizing and center indicator when displaying Loading screen
+ (void) startIndicatorDisableViewController: (UIViewController *) viewController ;
{
    CGRect parentFrame = viewController.view.frame;
    if ([viewController.view viewWithTag:RECT_TAG] != nil) {
        return;
    }
    
    UIView* blackRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, parentFrame.size.width, parentFrame.size.height)];
    blackRect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blackRect.contentMode = UIViewContentModeScaleToFill;
	blackRect.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
	blackRect.tag = RECT_TAG;
	[[viewController view] addSubview:blackRect];
    
	UIActivityIndicatorView *spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinny.tag = SPIN_TAG;
	spinny.center = CGPointMake(parentFrame.size.width/2,parentFrame.size.height/2);
    spinny.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    spinny.contentMode = UIViewContentModeCenter;
    [spinny startAnimating];
    [viewController.view addSubview:spinny];
    
    if (spinny) {
//        [spinny release];
    }
    
    if (blackRect) {
//        [blackRect release];
    }
}

// stop indicator animation with black screen
+ (void) stopIndicatorDisableViewController: (UIViewController *) viewController ;
{
    UIView *spinny = [viewController.view viewWithTag:SPIN_TAG];
    [spinny removeFromSuperview];
    UIView *blk = [viewController.view viewWithTag:RECT_TAG];
    [blk removeFromSuperview];
}

+ (void) startIndicatorDisableViewController: (UIViewController *) viewController willDisableNavigation:(BOOL)disable ;
{
    UIView *mainView = (disable) ? viewController.navigationController.view : viewController.view;
    CGRect parentFrame = mainView.frame;
    if ([mainView viewWithTag:RECT_TAG] != nil) {
        return;
    }
    
    UIView* blackRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, parentFrame.size.width, parentFrame.size.height)];
    blackRect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blackRect.contentMode = UIViewContentModeScaleToFill;
	blackRect.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
	blackRect.tag = RECT_TAG;
	[mainView addSubview:blackRect];
    
	UIActivityIndicatorView *spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinny.tag = SPIN_TAG;
	spinny.center = CGPointMake(parentFrame.size.width/2,parentFrame.size.height/2);
    spinny.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    spinny.contentMode = UIViewContentModeCenter;
    [spinny startAnimating];
    [mainView addSubview:spinny];
    
    if (spinny) {
//        [spinny release];
    }
    
    if (blackRect) {
//        [blackRect release];
    }
}

// stop indicator animation with black screen
+ (void) stopIndicatorDisableViewController: (UIViewController *) viewController willDisableNavigation:(BOOL)disable;
{
    UIView *mainView = (disable) ? viewController.navigationController.view : viewController.view;
    
    UIView *spinny = [mainView viewWithTag:SPIN_TAG];
    [spinny removeFromSuperview];
    UIView *blk = [mainView viewWithTag:RECT_TAG];
    [blk removeFromSuperview];
}



#define kLoadingHUDTag                          101
/*
 * Method : displayLoadingIndicatorOnView
 * Created By: DatNT8
 * Created Date: N/A
 * Param: (UIViewController *)viewController, (NSString *)text
 * Purpose: display loading indicator
 */

+ (void)displayLoadingIndicatorOnView:(UIViewController *)viewController withText:(NSString *)text;
{
    //    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:delegate.window animated:YES];
//    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
////    [progress setType:-1];
//    [progress setLabelText:text];
}

+ (void)displayLoadingIndicator:(UIView *)view withText:(NSString *)text;
{
    //    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:delegate.window animated:YES];
//    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:view animated:YES];
////    [progress setType:-1];
//    [progress setLabelText:text];
}

/*
 * Method : hideLoadingIndicatorOnView
 * Created By: DatNT8
 * Created Date: N/A
 * Param: (UIViewController *)viewController
 (BOOL)animated: whether will hide loading progress view with fading effect
 * Purpose: hide loading indicator
 */
+ (void)hideLoadingIndicatorOnView:(UIViewController *)viewController animated:(BOOL)animated;
{
//    [MBProgressHUD hideAllHUDsForView:viewController.view animated:animated];
}

+ (void)hideLoadingIndicator:(UIView *)view animated:(BOOL)animated;
{
//    [MBProgressHUD hideAllHUDsForView:view animated:animated];
}

/*
 * Method : hideLoadingIndicatorOnView
 * Created By: DatNT8
 * Created Date: N/A
 * Param: (UIViewController *)viewController
 * Purpose: hide loading indicator
 */
+ (void)hideLoadingIndicatorOnView:(UIViewController *)viewController;
{
    [CommonUtils hideLoadingIndicatorOnView:viewController animated:YES];
}

+ (void)hideLoadingIndicator:(UIView *)view;
{
    [CommonUtils hideLoadingIndicator:view animated:YES];
}



+ (NSString *) getBundleVersion;
{
    return [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

+ (NSString *) versionShortString;
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

// Method used to get app setting value by setting key
+ (NSString*) loadHTMLfile: (NSString *) fileName;
{
    NSString *path = [CommonUtils fullPathFromFile:[NSString stringWithFormat: @"%@", fileName]];
    
    NSError *error;
    NSString * value = [[NSString alloc] initWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    
    return value;
    // End DatNT8
    
}



+ (NSString *)fileNameStringSafe:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}


+ (NSString*)stringForKey:(NSString*)key inLanguage:(NSString *)language;
{
    NSString *path;
    path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]; // give your language type in pathForResource, i.e. "en" for english, "da" for Danish
    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    NSString* str=[languageBundle localizedStringForKey:key value:@"" table:nil];
    return str;
}


+ (NSString *)handleChartNameFromName:(NSString *)name;
{
    NSString *newName = [name stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    newName = [newName stringByRemovingPercentEncoding];
    
    return newName;
    

}

+ (BOOL)isStringNull:(id)obj;
{
    if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj length] != 0 && obj != [NSNull null]) {
        return NO;
    }
    
    return YES;
}

+ (void)animateTouchDownButton:(UIButton *)button;
{
    [CommonUtils animateTouchDownButton:button doneBlock:nil];

}

+ (void)animateTouchDownButton:(UIButton *)button doneBlock:(void(^)())doneBlock;
{
    
    [UIView animateWithDuration:0.15 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            button.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                button.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (doneBlock) {
                    doneBlock();
                }
            }];
        }];
    }];
    
}

+ (void)animateZoomInHiddenButton:(UIButton *)button;
{
    
    [UIView animateWithDuration:0.25 animations:^{
        button.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        button.alpha = 0.0f;
    } completion:^(BOOL finished) {
//        button.transform = CGAffineTransformIdentity;
    }];
    
}

+ (void)animateZoomOutVisibleButton:(UIButton *)button;
{
    
    [UIView animateWithDuration:0.25 animations:^{
        button.transform = CGAffineTransformIdentity;
        
        button.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        
        
    }];
    
}

+ (NSString *) stringFromTimeInterval:(double) seconds;
{
    int s = ((int)seconds) % 60;
    int m = ((int)seconds) / 60 % 60;
    int h = ((int)seconds) / 60 / 60;
    
    NSString *string = [NSString stringWithFormat:@"%d:%02d", m, s];
    if (h) {
        string = [NSString stringWithFormat:@"%d:%02d:%02d", h, m, s];
    }
    
    return string;
}


@end