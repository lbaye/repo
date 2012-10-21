//
//  SelectFriends.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "SelectFriends.h"
#import "CustomCheckbox.h"
#import "UIImageView+roundedCorner.h"
#import "UserFriends.h"
#import "UserInfo.h"

@implementation SelectFriends
@synthesize friendList;
@synthesize circleList;
@synthesize selectedFriends;
@synthesize selectedCircles;
@synthesize photoScrollView;
@synthesize circleScrollView;
@synthesize selectedScrollView;
@synthesize line2Image;
@synthesize filteredFriends;
@synthesize customSelection;
@synthesize delegate;
@synthesize smAppDelegate;
@synthesize searchBar;

- (id) initWithFrame:(CGRect)frame friends:(NSMutableArray*)friends circles:(NSMutableArray*)circles
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        friendList = [[NSMutableArray alloc] initWithArray:friends];
        circleList = [[NSMutableArray alloc] initWithArray:circles];
        filteredFriends = [[NSMutableArray alloc] initWithArray:friends];
        self.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
        selectedFriends = [[NSMutableArray alloc] init];
        selectedCircles = [[NSMutableArray alloc] init];
        customSelection.friends = [[NSMutableArray alloc] init];
        customSelection.circles = [[NSMutableArray alloc] init];
        for (int i=0; i < filteredFriends.count; i++) {
            UserInfo *aUser = [filteredFriends objectAtIndex:i];
            NSLog(@"SelectFriends:filtered friend:%@", aUser.userId);
            if ([smAppDelegate.locSharingPrefs.custom.friends containsObject:aUser.userId]) {
                [selectedFriends addObject:[NSNumber numberWithInt:1]];
                [customSelection.friends addObject:aUser.userId];
            } else
                [selectedFriends addObject:[NSNumber numberWithInt:0]];
        }
        photoScrollView = [[UIScrollView alloc] init];
        circleScrollView= [[UIScrollView alloc] init];
        circleScrollView.hidden = TRUE;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//
// [UIColor colorWithRed:148.0/255.0 green:193.0/255.0 blue:28.0/255.0 alpha:1.0].CGColor]
//
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int buttonWidth = self.frame.size.width/4*3/2;
    
    NSString *lblText = [NSString stringWithString:@"Choose a subgroup of friends"];
    CGSize txtSize = [lblText sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:24]];
    CGRect lblFrame = CGRectMake(10, 10, txtSize.width, txtSize.height);                
    UILabel *lbl = [[UILabel alloc] initWithFrame:lblFrame];
    lbl.font = [UIFont fontWithName:@"Helvetica" size:18];
    lbl.text = lblText;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor blackColor];
    [self addSubview:lbl];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, lblFrame.origin.y+lblFrame.size.height+1, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    [self addSubview:lineImage];
    
    // Create top buttons
    // Select
    CGRect selFrame = CGRectMake(0, lineFrame.origin.y+2+7, buttonWidth, 35);
    UIButton *selButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selButton addTarget:self 
                  action:@selector(selButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    selButton.frame = selFrame;
    selButton.backgroundColor = [UIColor clearColor];
    [selButton setTitle:@"Select or search:" forState:UIControlStateNormal];
    [selButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    [self addSubview:selButton];
    
    // Search field
    CGRect searchFrame = CGRectMake(5+selFrame.size.width+2, lineFrame.origin.y+2+7, buttonWidth, 35);
    searchBar = [[UISearchBar alloc] initWithFrame:searchFrame];
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleBlackOpaque;
    searchBar.translucent = YES;
    [self addSubview:searchBar];

    
    // Separator
    CGRect sepFrame = CGRectMake(searchFrame.origin.x+searchFrame.size.width+10, selFrame.origin.y, 1, 35);
    UIImageView *sepImageView = [[UIImageView alloc] initWithFrame:sepFrame];
    sepImageView.image = [UIImage imageNamed:@"sp.png"];
    [self addSubview:sepImageView];
    
    // Circles
    CGSize circleSize = [@"Circle..." sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    CGRect circleFrame = CGRectMake(sepFrame.origin.x+sepFrame.size.width+10, 
                                    lineFrame.origin.y+7+(35-circleSize.height)/2, 
                                    circleSize.width, circleSize.height);
    UIButton *circleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [circleBtn addTarget:self 
                  action:@selector(circleButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    circleBtn.frame = circleFrame;
    circleBtn.backgroundColor = [UIColor clearColor];
    circleBtn.titleLabel.textAlignment = UITextAlignmentLeft;
    [circleBtn setTitle:@"Circle..." forState:UIControlStateNormal];
    [circleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [circleBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    [self addSubview:circleBtn];
    
    // Create the line with image tab_arrow.png
    CGRect line2Frame = CGRectMake(0, searchFrame.origin.y+searchFrame.size.height+1, 310, 7);
    line2Image = [[UIImageView alloc] initWithFrame:line2Frame];
    line2Image.image = [UIImage imageNamed:@"line_arrow_up_left.png"];
    line2Image.backgroundColor = [UIColor clearColor];
    [self addSubview:line2Image];
    
    //
    UIView *photoSel = [[UIView alloc] initWithFrame:CGRectMake(0, line2Frame.origin.y+7, self.frame.size.width, 250)];
    photoSel.backgroundColor = [UIColor whiteColor];
    
    // Photo scroll view
    CGRect photoFrame = CGRectMake(0, 0, self.frame.size.width, 210);
    // Remove all subviews
    for (UIView *aView in [photoScrollView subviews]) {
        [aView removeFromSuperview];
    }
    photoScrollView.frame = photoFrame;
    photoScrollView.backgroundColor = [UIColor clearColor];
    CGSize photeSelContentsize = CGSizeMake((photoFrame.size.width)*ceil(filteredFriends.count/4.0), photoFrame.size.height);
    photoScrollView.contentSize = photeSelContentsize;
    float imgWidth = (photoFrame.size.width-35)/4;
    for (int i=0; i<filteredFriends.count; i++) {
        UserInfo *aFriend = (UserInfo*) [filteredFriends objectAtIndex:i];
        CGRect imgFrame = CGRectMake((i%4)*(imgWidth+10), (i/4)*(imgWidth+35)+5, imgWidth, imgWidth);
        NSLog(@"friend:%@, x=%f,y=%f,width=%f,height=%f", aFriend.userId, imgFrame.origin.x, imgFrame.origin.y,
              imgFrame.size.width, imgFrame.size.height);
        
        //NSString *imgName = [NSString stringWithFormat:@"Photo-%d.png",i%4];
        UIImageView *friendImg = [UIImageView imageViewWithRectImage:imgFrame andImage:aFriend.icon withCornerradius:10.0f];
        friendImg.tag = 20000+i;
        friendImg.userInteractionEnabled = YES;
        int currState = [(NSNumber*)[selectedFriends objectAtIndex:i] intValue] ;
        if (currState == 1)
            [friendImg setBorderColor:[UIColor colorWithRed:148.0/255.0 green:193.0/255.0 blue:28.0/255.0 alpha:1.0]];
            
        // First name
        UILabel *firstName = [[UILabel alloc] initWithFrame:CGRectMake(imgFrame.origin.x, 
                                                                       imgFrame.origin.y+imgFrame.size.height, 
                                                                       imgWidth, 16)];
        firstName.text = aFriend.firstName; 
        firstName.font = [UIFont fontWithName:@"Helvetica" size:11];
        firstName.backgroundColor = [UIColor clearColor];
        firstName.textColor = [UIColor blackColor];
        firstName.textAlignment = UITextAlignmentCenter;
        [photoScrollView addSubview:firstName];
        
        // Last name
        UILabel *lastName = [[UILabel alloc] initWithFrame:CGRectMake(imgFrame.origin.x, 
                                                                       imgFrame.origin.y+imgFrame.size.height+15, 
                                                                       imgWidth, 16)];
        lastName.text = aFriend.lastName; 
        lastName.font = [UIFont fontWithName:@"Helvetica" size:11];
        lastName.backgroundColor = [UIColor clearColor];
        lastName.textColor = [UIColor blackColor];
        lastName.textAlignment = UITextAlignmentCenter;
        [photoScrollView addSubview:lastName];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        [friendImg addGestureRecognizer:tap];
        [tap release];
        [photoScrollView addSubview:friendImg];
    }

    [photoSel addSubview:photoScrollView];
    
    // Circles scroll view
    CGRect circleScrollFrame = CGRectMake(0, 0, self.frame.size.width, 210);
    circleScrollView.frame = circleScrollFrame;
    circleScrollView.backgroundColor = [UIColor clearColor];
    CGSize circleSelContentsize = CGSizeMake(circleScrollFrame.size.width, circleScrollFrame.size.height*2);
    circleScrollView.contentSize = circleSelContentsize;
    
    for (int i=0;i<circleList.count;i++) {
        UserCircle *aCircle = (UserCircle*) [circleList objectAtIndex:i];
        CustomCheckbox *circle = [[CustomCheckbox alloc] initWithFrame:CGRectMake(0, i*(5+45), circleScrollFrame.size.width, 45) 
                                                            boxLocType:LabelPositionLeft 
                                                              numBoxes:1 
                                                               default:[NSArray arrayWithObject:[NSNumber numberWithInt:0]] 
                                                                labels:[NSArray arrayWithObject:aCircle.circleName]];
        circle.delegate = self;
        circle.tag = 13000+i;
        [circleScrollView addSubview:circle];
    }
    [photoSel addSubview:circleScrollView];
     
    // Selection buttons
    CGRect unselectFrame = CGRectMake(self.frame.size.width/2-5-buttonWidth, 
                                      photoFrame.origin.y+2+photoFrame.size.height, 
                                      buttonWidth, 35);
    UIButton *unselectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [unselectBtn addTarget:self 
                  action:@selector(unselectAll:)
        forControlEvents:UIControlEventTouchUpInside];
    unselectBtn.frame = unselectFrame;
    unselectBtn.backgroundColor = [UIColor clearColor];
    unselectBtn.titleLabel.textAlignment = UITextAlignmentRight;
    [unselectBtn setTitle:@"Unselect all" forState:UIControlStateNormal];
    [unselectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [unselectBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0]];
    [photoSel addSubview:unselectBtn];
    
    CGRect selectFrame = CGRectMake(self.frame.size.width/2 + 5, 
                                    photoFrame.origin.y+2+photoFrame.size.height, 
                                      buttonWidth, 35);
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectBtn addTarget:self 
                    action:@selector(selectAll:)
          forControlEvents:UIControlEventTouchUpInside];
    selectBtn.frame = selectFrame;
    selectBtn.backgroundColor = [UIColor clearColor];
    selectBtn.titleLabel.textAlignment = UITextAlignmentLeft;
    [selectBtn setTitle:@"Add all" forState:UIControlStateNormal];
    [selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0]];
    [photoSel addSubview:selectBtn];
    
    [self addSubview:photoSel];
    
    // Submission buttons
    CGRect cancelFrame = CGRectMake((self.frame.size.width/2-buttonWidth)/2, 
                                    photoSel.frame.origin.y+2+photoSel.frame.size.height, 
                                    buttonWidth, 30);
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self 
                    action:@selector(cancelSel:)
          forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = cancelFrame;
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0]];
    [self addSubview:cancelBtn];
    
    // Separator
    CGRect sep2Frame = CGRectMake(self.frame.size.width/2, 
                                  photoSel.frame.origin.y+2+photoSel.frame.size.height, 
                                  1, 30);
    UIImageView *sep2ImageView = [[UIImageView alloc] initWithFrame:sep2Frame];
    sep2ImageView.image = [UIImage imageNamed:@"sp.png"];
    [self addSubview:sep2ImageView];
    
    CGRect okFrame = CGRectMake(self.frame.size.width/2+(self.frame.size.width/2-buttonWidth)/2, 
                                    photoSel.frame.origin.y+2+photoSel.frame.size.height, 
                                    buttonWidth, 30);
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn addTarget:self 
                    action:@selector(saveSel:)
          forControlEvents:UIControlEventTouchUpInside];
    okBtn.frame = okFrame;
    okBtn.backgroundColor = [UIColor clearColor];
    okBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    [okBtn setTitle:@"Ok" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [okBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0]];
    [self addSubview:okBtn];
}

- (void) selButtonClicked:(id) sender {
    NSLog(@"SelectFriends: selButtonClicked");
    line2Image.image = [UIImage imageNamed:@"line_arrow_up_left.png"];
    photoScrollView.hidden = FALSE;
    circleScrollView.hidden = TRUE;
}

- (void) circleButtonClicked:(id) sender {
    NSLog(@"SelectFriends: circleButtonClicked");
    line2Image.image = [UIImage imageNamed:@"line_arrow_up_right.png"];
    photoScrollView.hidden = TRUE;
    circleScrollView.hidden = FALSE;
}

- (void) unselectAll:(id) sender {
    NSLog(@"SelectFriends: unselectAll called");
    if (photoScrollView.isHidden == FALSE) {  // In friend selection tab
        for (int i=0; i < selectedFriends.count; i++) {
            UIImageView *imgView = (UIImageView*) [photoScrollView viewWithTag:20000+i];
            
            [imgView setBorderColor:[UIColor clearColor]];
            [selectedFriends replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
        }
    } 
}

- (void) selectAll:(id) sender {
    NSLog(@"SelectFriends: selectAll called");
    for (int i=0; i < selectedFriends.count; i++) {
        UIImageView *imgView = (UIImageView*) [photoScrollView viewWithTag:20000+i];
        
        [imgView setBorderColor:[UIColor colorWithRed:148.0/255.0 green:193.0/255.0 blue:28.0/255.0 alpha:1.0]];
        [selectedFriends replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:1]];
    }

    
}

- (void) cancelSel:(id) sender {
    [self removeFromSuperview];
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(selectFriendsCancelled)]) {
        [self.delegate selectFriendsCancelled];
    }
}

- (void) saveSel:(id) sender {
    [self removeFromSuperview];
    NSLog(@"Selected friends:");
    for (int i=0; i < customSelection.friends.count; i++)
        NSLog(@"id=%@", [customSelection.friends objectAtIndex:i]);
    NSLog(@"Selected circles:");
    for (int i=0; i < customSelection.circles.count; i++)
        NSLog(@"id=%@", [customSelection.circles objectAtIndex:i]);

    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(selectFriendsDone:)]) {
        [self.delegate selectFriendsDone:customSelection];
    }
}

- (void) imageTapped:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    NSLog(@"SelectFriends:imageTapped - %d", gesture.view.tag-20000);
    
    int imageNum = gesture.view.tag-20000;
    
    UIImageView *imgView = (UIImageView*) gesture.view;
    int currState = [(NSNumber*)[selectedFriends objectAtIndex:imageNum] intValue] ;
    if (currState == 0) {
        [imgView setBorderColor:[UIColor colorWithRed:148.0/255.0 green:193.0/255.0 blue:28.0/255.0 alpha:1.0]];
        [selectedFriends replaceObjectAtIndex:imageNum withObject:[NSNumber numberWithInt:1]];
        UserInfo *aFriend = (UserInfo*) [filteredFriends objectAtIndex:imageNum];
        [customSelection.friends addObject:aFriend.userId];
    } else {
        [imgView setBorderColor:[UIColor clearColor]];
        [selectedFriends replaceObjectAtIndex:imageNum withObject:[NSNumber numberWithInt:0]];
        UserInfo *aFriend = (UserInfo*) [filteredFriends objectAtIndex:imageNum];
        [customSelection.friends removeObject:aFriend.userId];
    }

}

// Custom Checkbox delegate methods
- (void) checkboxClicked:(int)indx withState:(int)clicked sender:(id)sender {
    CustomCheckbox *chkBox = (CustomCheckbox*) sender;
    int circleIndx = chkBox.tag - 13000;
    NSString * circleName = [[circleList objectAtIndex:circleIndx] circleName];
    NSLog(@"SelectFriend:CustomCheckbox indx:%d state:%d tag:%d name:%@", indx, clicked, chkBox.tag, circleName);
    if (clicked == 1)
        [customSelection.circles addObject:circleName];
    else
        [customSelection.circles removeObject:circleName];
}

//search bar delegate method starts
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText 
{   
    //searchBar.text = searchText;
    
    [filteredFriends removeAllObjects];
    for (int i=0; i<friendList.count; i++)
    {
        UserInfo *item = [friendList objectAtIndex:i];
        if ([item.firstName rangeOfString:searchText].location != NSNotFound ||
            [item.lastName rangeOfString:searchText].location != NSNotFound ||
            [searchText isEqualToString:@""])
            [filteredFriends addObject:item];
    }
    //[self setNeedsDisplay];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar 
{
    NSLog(@"SelectFriends searchBarTextDidEndEditing: text =%@", theSearchBar.text);
    if (theSearchBar.text == nil || [theSearchBar.text isEqualToString:@""]) {
        [filteredFriends removeAllObjects];
        [filteredFriends addObjectsFromArray:friendList];
    }
    [self setNeedsDisplay];
    [theSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{

    [searchBar resignFirstResponder];    
}

@end
