//
//  InfoSharing.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#define INFO_SHARING_ROW_HEIGHT 45

@interface InfoSharing : UIScrollView
- (UIScrollView*) initWithFrame:(CGRect)frame infoList:(NSArray*)infoList
                        defList:(NSArray*)defList sender:(id) sender;

@end
