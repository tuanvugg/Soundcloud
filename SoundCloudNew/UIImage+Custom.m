//
//  UIImage+Custom.m
//  SoundCloudNew
//
//  Created by Trung Đức on 3/22/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "UIImage+Custom.h"
#import "Constant.h"

@implementation UIImage(Custom)

+ (instancetype)customWithTintColor:(UIColor *)tintColor duration:(NSTimeInterval)duration
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    short index = 1;
    while ( index <= 32 )
    {
        NSString *imageName = [NSString stringWithFormat:@"%d", index++];
        UIImage *image = [UIImage imageNamed:imageName];
        if ( image == nil ) break;
        
        [images addObject:[image imageTintedWithColor:kAppColor]];
    }
    
    return [self animatedImageWithImages:images duration:duration];
}

- (instancetype)imageTintedWithColor:(UIColor *)tintColor
{
    CGRect imageBounds = CGRectMake( 0, 0, self.size.width, self.size.height );
    
    UIGraphicsBeginImageContextWithOptions( self.size, NO, self.scale );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM( context, 0, self.size.height );
    CGContextScaleCTM( context, 1.0, -1.0 );
    CGContextClipToMask( context, imageBounds, self.CGImage );
    
    [tintColor setFill];
    CGContextFillRect( context, imageBounds );
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end
