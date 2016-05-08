//
//  Constant.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define kTitlePlaylistDownload @"Downloads"


#define kHistoryPlaylistIndex                       [NSNumber numberWithInt:1]


//Database

#define kDatabaseName                               @"SCDatabase"






//Color

#define kAppDefaultColor                            [UIColor redColor]

#define kAppColor                                   (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppColor"]]

#define kPlaylistDefaultImageColor                  [UIColor lightGrayColor]




//SoundCloud API

#define kSoundCloudAppID                            @"a453dc1eaf606c2c7c95e263e0c4f385"

#define kSoundCloudExploreURL                       @"https://api-v2.soundcloud.com/explore/%@"

#define kSoundCloudAutocompleteURL                  @"https://api.soundcloud.com/search/suggest"

#define kSoundCloudSearchTrackURL                   @"https://api.soundcloud.com/tracks.json"



#define kSoundCloudAutoCompleteDefaultLimit         15


#define kSoundCloudSearchTrackDefaultOffset         0
#define kSoundCloudSearchTrackDefaultLimit          25
#define kSoundCloudSearchTrackLoadMore              25


#define kSoundCloudExploreDefaultOffset             0
#define kSoundCloudExploreDefaultLimit              50
#define kSoundCloudExploreDLoadMore                 50

//Image



#define kDefaultTrackImageName                      @"TrackDefault1"

#define kDefaultPlaylistImageName                   @"tab-playlists-selected"

#define kDefaultGenreImageName                      @"TrackDefault1"



#define kBtnMoreImageName                           @"ButtonMore"

#define kBtnNewPlaylistImageName                    @"icon_addplaylist"

#define kBtnPlayingImageName                        @"music_note"

#define kBtnRemoveAllImageName                      @"icon_toolbar_trash"

#define kThumbSliderImageName                       @"slider_thumb"




#define kSuggestTrackImageName                      @"Track1"

#define kSuggestUserImageName                       @"User"



#define kAppLoadingImage                            @"techkids"

#define kSearchEmptyImage                           @"searchImage-1"




//Button title

#define kBtnNewPlaylistTitle                        @"New Playlist..."


#endif /* Constant_h */
