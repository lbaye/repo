//
//  MeetUpListButtonsView.m
//  SocialMaps
//
//  Created by Warif Rishi on 9/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MeetUpListButtonsView.h"
#import "MeetUpRequest.h"
#import "AppDelegate.h"
#import "CustomAlert.h"

@implementation MeetUpListButtonsView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        buttonAccept = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAccept.frame = CGRectMake(30, 0, 70, 30);
        [buttonAccept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttonAccept setTitleColor:[UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0] forState:UIControlStateSelected];
        [buttonAccept setTitle:@"Accept" forState:UIControlStateNormal];
        [buttonAccept setTitle:@"Accepted" forState:UIControlStateSelected];
        [buttonAccept.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
        [buttonAccept addTarget:self action:@selector(actionAccetpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonAccept];
        
        buttonDecline = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonDecline.frame = CGRectMake(110, 0, 70, 30);
        [buttonDecline setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttonDecline setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [buttonDecline setTitle:@"Decline" forState:UIControlStateNormal];
        [buttonDecline setTitle:@"Declined" forState:UIControlStateSelected];
        [buttonDecline.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
        [buttonDecline addTarget:self action:@selector(actionDeclineButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonDecline];
        
        buttonIgnore = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonIgnore.frame = CGRectMake(190, 0, 70, 30);
        [buttonIgnore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonIgnore setTitle:@"Ignore" forState:UIControlStateNormal];
        [buttonIgnore setTitle:@"Ignored" forState:UIControlStateSelected];
        [buttonIgnore.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
        [buttonIgnore addTarget:self action:@selector(actionIgnoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonIgnore];
        
        [self resetButtons:nil];
    }
    return self;
}

- (void)actionAccetpButton:(id)sender
{
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:cellButton:)]) {
        [delegate buttonClicked:@"yes" cellButton:sender];
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [meetUpReq.meetUpRsvpYes addObject:smAppDelegate.userId];
        [meetUpReq.meetUpRsvpNo removeObject:smAppDelegate.userId];
        [meetUpReq.meetUpRsvpIgnore removeObject:smAppDelegate.userId];
        [self resetButtons:sender];
        [self showAlert:[NSString stringWithFormat:@"You have accepted %@'s meet-up request",meetUpReq.meetUpSender]];
    }
}

- (void)actionDeclineButton:(id)sender
{
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:cellButton:)]) {
        [delegate buttonClicked:@"no" cellButton:sender];
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [meetUpReq.meetUpRsvpNo addObject:smAppDelegate.userId];
        [meetUpReq.meetUpRsvpYes removeObject:smAppDelegate.userId];
        [meetUpReq.meetUpRsvpIgnore removeObject:smAppDelegate.userId];
        [self resetButtons:sender];
        [self showAlert:[NSString stringWithFormat:@"You have declined %@'s meet-up request",meetUpReq.meetUpSender]];
    }
}

- (void)actionIgnoreButton:(id)sender
{
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:cellButton:)]) {
        [delegate buttonClicked:@"maybe" cellButton:sender];
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [meetUpReq.meetUpRsvpIgnore addObject:smAppDelegate.userId];
        [meetUpReq.meetUpRsvpYes removeObject:smAppDelegate.userId];
        [meetUpReq.meetUpRsvpNo removeObject:smAppDelegate.userId];
        [self resetButtons:sender];
        [self showAlert:[NSString stringWithFormat:@"You have ignored %@'s meet-up request",meetUpReq.meetUpSender]];
    }
}

- (void)showAlert:(NSString*)msg
{
    [CustomAlert setBackgroundColor:[UIColor grayColor] 
                    withStrokeColor:[UIColor grayColor]];
    CustomAlert *acceptAlert = [[CustomAlert alloc]
                                initWithTitle:@"Meet-up request!"
                                message:msg
                                delegate:nil
                                cancelButtonTitle:@"Done"
                                otherButtonTitles:nil];
    
    [acceptAlert show];
    [acceptAlert autorelease];
}

- (void)resetButtons:(id)sender
{
    [buttonAccept setBackgroundImage:[UIImage imageNamed:@"btn_bg_green_small"] forState:UIControlStateNormal];
    buttonAccept.selected = NO;
    [buttonDecline setBackgroundImage:[UIImage imageNamed:@"btn_bg_gray_small.png"] forState:UIControlStateNormal];
    buttonDecline.selected = NO;
    [buttonIgnore setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
    buttonIgnore.selected = NO;
    buttonIgnore.userInteractionEnabled = YES;
    buttonDecline.userInteractionEnabled = YES;
    buttonAccept.userInteractionEnabled = YES;
    
    if (sender) {
        [sender setBackgroundImage:nil forState:UIControlStateNormal];
        ((UIButton*)sender).selected = YES;
        ((UIButton*)sender).userInteractionEnabled = NO;
    }
}

- (void)adjustButtons:(MeetUpRequest*)_meetUpReq
{
    meetUpReq = _meetUpReq;
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self resetButtons:nil];
    
    for (int i = 0; i < [meetUpReq.meetUpRsvpYes count]; i++) {
        if ([[meetUpReq.meetUpRsvpYes objectAtIndex:i] isEqualToString:smAppDelegate.userId]) {
            [self resetButtons:buttonAccept];
            break;
        }
    }
  
    for (int i = 0; i < [meetUpReq.meetUpRsvpNo count]; i++) {
        if ([[meetUpReq.meetUpRsvpNo objectAtIndex:i] isEqualToString:smAppDelegate.userId]) {
            [self resetButtons:buttonDecline];
            break;
            
        }
    }
    
    for (int i = 0; i < [meetUpReq.meetUpRsvpIgnore count]; i++) {
        if ([[meetUpReq.meetUpRsvpIgnore objectAtIndex:i] isEqualToString:smAppDelegate.userId]) {
            [self resetButtons:buttonIgnore];
            break;
        }
    }
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
