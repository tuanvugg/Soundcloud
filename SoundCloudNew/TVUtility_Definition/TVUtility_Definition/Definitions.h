//
//  Definitions.h
//  Hi-IncreLocks
//
//  Created by tuanhi on 3/27/16.
//  Copyright © 2016 tuanhi. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h


#define kLinkAppstore                               @"http://linkappstorehere.com"
#define kAppstoreID                                 @"552035781"



#define kButtonTitle_No             @"No"
#define kButtonTitle_Yes            @"Yes"
#define kButtonTitle_OK             @"OK"






///DO NOT CHANGE THIS
#define kTotalOverlayLockscreenCount                (IS_IPHONE_6_PLUS ? kTotalOverlayLockscreenCount_IPHONE6PLUS : IS_IPHONE_6 ? kTotalOverlayLockscreenCount_IPHONE6 : IS_IPHONE_5 ? kTotalOverlayLockscreenCount_IPHONE5 : IS_IPHONE_4 ? kTotalOverlayLockscreenCount_IPHONE4 : kTotalOverlayLockscreenCount_IPHONE4 )



//
//














@interface Definitions : NSObject

@end

#endif /* Definitions_h */
