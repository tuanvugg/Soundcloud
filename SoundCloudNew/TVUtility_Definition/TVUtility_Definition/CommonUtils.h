//
//  CommonUtils.h
//
//


#ifndef CommonUtils_h
#define CommonUtils_h


#import <Foundation/Foundation.h>
#import "AppDelegate.h"



#ifndef APPDELEGATE
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#endif



#ifndef F_RELEASE
#define F_RELEASE(__p) {if(__p!=nil){[__p release]; __p=nil;}}
#endif

#ifndef LOCALIZE
#define LOCALIZE(__p) NSLocalizedString(__p, __p)
#endif

#ifndef IS_IPHONE_4
#define IS_IPHONE_4 ( [ [ UIScreen mainScreen ] bounds ].size.height == 480 )
#endif

#ifndef IS_IPHONE_5
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )
#endif

#ifndef IS_IPHONE_6
#define IS_IPHONE_6 ( [ [ UIScreen mainScreen ] bounds ].size.height == 667 )
#endif


#ifndef IS_IPHONE_6_PLUS
#define IS_IPHONE_6_PLUS ( [ [ UIScreen mainScreen ] bounds ].size.height == 736 )
#endif


#ifndef ISIPAD
#define ISIPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif

#ifndef ISPORTRAIT
#define ISPORTRAIT (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation]))
#endif

#ifndef DegreesToRadians
#define DegreesToRadians(__p) (__p * M_PI / 180)
#endif

#ifndef RadiansToDegrees
#define RadiansToDegrees(__p) (__p * 180/M_PI)
#endif

#ifndef NSStringFromBOOL
#define NSStringFromBOOL(aBOOL)    aBOOL? @"YES" : @"NO"
#endif


#ifndef SYSTEM_VERSION_EQUAL_TO
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#endif

#ifndef SYSTEM_VERSION_GREATER_THAN
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#endif

#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif

#ifndef SYSTEM_VERSION_LESS_THAN
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#endif

#ifndef SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#endif

#define kWindowSize                 ([[UIScreen mainScreen]currentMode].size)
#define kApplicationFrame           ([[UIScreen mainScreen]applicationFrame].size)

#define UIColorFromHEX(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


CGAffineTransform aspectFit(CGRect innerRect, CGRect outerRect);


//CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
//CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@interface NSString(reverseString)

-(NSString *) reverseString;

@end

@interface UIImage (scale)

-(UIImage*)scaleToSize:(CGSize)size;
-(UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)scaleToMaxWidth:(float)maxWidth
                   maxHeight:(float) maxHeight;

+ (UIImage *)captureImageFromView:(UIView *)view inFrame:(CGRect )captureFrame;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image;

- (UIImage *)scaleAndRotateImage;

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
- (UIImage*) roundCorneredRadius:(CGFloat)r;


@end

@interface CommonUtils : NSObject {
    
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path;
+ (NSString *)pathForSourceFile:(NSString *)file inDirectory:(NSString *)directory skipICloudBackup:(BOOL)skipBackup;
+ (NSString *)pathForSourceFile:(NSString *)file inDirectory:(NSString *)directory;
+ (NSString *)pathLibraryForSourceFile:(NSString *)file inDirectory:(NSString *)directory;
+ (NSString *)pathCacheForSourceFile:(NSString *)file inDirectory:(NSString *)directory;
+ (NSString *)pathTmpForSourceFile:(NSString *)file inDirectory:(NSString *)directory;
+ (void)cleanTempFolder;

+ (NSString *)fullPathFromFile:(NSString *)path;
+ (NSString *)bundlePathForFile:(NSString *)file inDirectory:(NSString *)dir;
+ (NSString *)bundlePathForDirectory:(NSString *)dir;

+ (void) openURLExternalHandlerForLink: (NSString *) urlLink;
+ (BOOL) canOpenLink: (NSString *) urlLink;

+ (void) copyFilePlistIfNeccessaryForFileName: (NSString *) filename withFileType:(NSString *)fileType;

+ (void) showAlertViewWithTitle: (NSString *) title
                        message:(NSString*)msg
              cancelButtonTitle:(NSString*)cancelTitle;

+ (void) showAlertViewWithTitle: (NSString *) title
                        message:(NSString*)msg
              cancelButtonTitle:(NSString*)cancelTitle
              otherButtonTitles: (NSString *) otherButtonTitles, ...;

+ (void) showAlertViewWithTag: (NSInteger) tag
                     delegate:(id) delegate
                    withTitle: (NSString *) title
                      message:(NSString*)msg
            cancelButtonTitle:(NSString*)cancelTitle
            otherButtonTitles: (NSString *) otherButtonTitles, ... ;



+ (BOOL) isDeviceSupportMultitasking;
+ (BOOL) isIOS5OrGreater;
+ (BOOL) isIOS5O1rGreater;
+ (BOOL) isIOS51rGreater;

+ (void) showNetworkIndicator;
+ (void) hideNetworkIndicator;

+ (void) startIndicatorDisableViewController: (UIViewController *) viewController ;
+ (void) stopIndicatorDisableViewController: (UIViewController *) viewController ;

+ (void) startIndicatorDisableViewController: (UIViewController *) viewController willDisableNavigation:(BOOL)disable ;
+ (void) stopIndicatorDisableViewController: (UIViewController *) viewController willDisableNavigation:(BOOL)disable;




+ (void)displayLoadingIndicatorOnView:(UIViewController *)viewController withText:(NSString *)text;
+ (void)hideLoadingIndicatorOnView:(UIViewController *)viewController animated:(BOOL)animated;

+ (void)displayLoadingIndicator:(UIView *)view withText:(NSString *)text;
+ (void)hideLoadingIndicator:(UIView *)view animated:(BOOL)animated;
+ (void)hideLoadingIndicator:(UIView *)view;


+ (NSString *) getBundleVersion;
+ (NSString *) versionShortString;

+ (NSString*) loadHTMLfile: (NSString *) fileName;


+ (UIImage*)loadLocalImage:(NSString*)fileName;

+ (NSString *)fileNameStringSafe:(NSString *)fileName;



+ (NSString*)stringForKey:(NSString*)key inLanguage:(NSString *)language;

+ (NSString *)handleChartNameFromName:(NSString *)name;

+ (BOOL)isStringNull:(id)obj;

+ (void)animateTouchDownButton:(UIButton *)button;
+ (void)animateTouchDownButton:(UIButton *)button doneBlock:(void(^)())doneBlock;

+ (void)animateZoomInHiddenButton:(UIButton *)button;
+ (void)animateZoomOutVisibleButton:(UIButton *)button;


+ (NSString *) stringFromTimeInterval:(double) seconds;
    
@end

#endif
