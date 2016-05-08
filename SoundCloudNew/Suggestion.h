






//
//  Suggestion.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/25/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Suggestion : NSObject

@property(nonatomic,copy) NSString *query;
@property(nonatomic,copy) NSString *kind;
@property(nonatomic,assign) NSInteger trackID;
@property(nonatomic,assign) NSInteger score;

- (instancetype)initWithJsonDict:(NSDictionary *)json;

@end
