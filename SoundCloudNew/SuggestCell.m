//
//  SuggestCell.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/25/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "SuggestCell.h"
#import "Constant.h"

@implementation SuggestCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displaySuggestion:(Suggestion *)suggestion;
{
    _lblTitle.text = suggestion.query;
    if ([suggestion.kind isEqualToString:@"track"]) {
        _imvKind.image = [UIImage imageNamed:kSuggestTrackImageName];
    } else {
        _imvKind.image = [UIImage imageNamed:kSuggestUserImageName];
    }
}

@end
