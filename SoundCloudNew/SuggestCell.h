//
//  SuggestCell.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/25/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Suggestion.h"

@interface SuggestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imvKind;

- (void)displaySuggestion:(Suggestion *)suggestion;

@end
