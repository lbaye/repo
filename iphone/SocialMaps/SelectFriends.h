//
//  SelectFriends.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectFriends : UIView <UISearchBarDelegate> {
    NSMutableArray  *friendList;
    NSMutableArray  *selectedFriends;
    NSMutableArray  *filteredFriends;
    UIScrollView    *photoScrollView;
    UIScrollView    *circleScrollView;
    UIScrollView    *selectedScrollView;
    UIImageView     *line2Image;
}
@property (nonatomic, retain) NSMutableArray *friendList;
@property (nonatomic, retain) NSMutableArray *filteredFriends;
@property (nonatomic, retain) NSMutableArray *selectedFriends;
@property (nonatomic, retain) UIScrollView * photoScrollView;
@property (nonatomic, retain) UIScrollView * circleScrollView;
@property (nonatomic, retain) UIScrollView * selectedScrollView;
@property (nonatomic, retain) UIImageView *line2Image;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
- (id) initWithFrame:(CGRect)frame friends:(NSMutableArray*)friendList;
@end
