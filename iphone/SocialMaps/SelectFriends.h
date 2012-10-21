//
//  SelectFriends.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCheckbox.h"
#import "AppDelegate.h"

typedef struct _CustomSelection {
    NSMutableArray  *friends;
    NSMutableArray  *circles;
} CustomSelection;

@protocol SelectFriendsDelegate <NSObject>

- (void) selectFriendsDone:(CustomSelection) selection;
- (void) selectFriendsCancelled;

@end


@interface SelectFriends : UIView <UISearchBarDelegate, CustomCheckboxDelegate> {
    NSMutableArray  *friendList;
    NSMutableArray  *circleList;
    NSMutableArray  *selectedFriends;
    NSMutableArray  *selectedCircles;
    NSMutableArray  *filteredFriends;
    UIScrollView    *photoScrollView;
    UIScrollView    *circleScrollView;
    UIScrollView    *selectedScrollView;
    UIImageView     *line2Image;
    CustomSelection customSelection;
    id<SelectFriendsDelegate>   delegate;
    AppDelegate     *smAppDelegate;
    UISearchBar     *searchBar;
}
@property (nonatomic, retain) NSMutableArray *friendList;
@property (nonatomic, retain) NSMutableArray *circleList;
@property (nonatomic, retain) NSMutableArray *filteredFriends;
@property (nonatomic, retain) NSMutableArray *selectedFriends;
@property (nonatomic, retain) NSMutableArray *selectedCircles;
@property (nonatomic, retain) UIScrollView * photoScrollView;
@property (nonatomic, retain) UIScrollView * circleScrollView;
@property (nonatomic, retain) UIScrollView * selectedScrollView;
@property (nonatomic, retain) UIImageView *line2Image;
@property (nonatomic) CustomSelection customSelection;
@property (nonatomic, retain) id<SelectFriendsDelegate>   delegate;
@property (nonatomic, retain) AppDelegate     *smAppDelegate;
@property (nonatomic, retain) UISearchBar *searchBar;

- (id) initWithFrame:(CGRect)frame friends:(NSMutableArray*)friendList circles:(NSMutableArray*)circleList;
@end
