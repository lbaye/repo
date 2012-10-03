//
//  MeetUpListButtonsView.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeetUpRequest;

@protocol MeetUpListButtonsDelegate<NSObject>
- (void) buttonClicked:(NSString*)actionName cellButton:(id)sender;
@end

@interface MeetUpListButtonsView : UIView 
{
    UIButton *buttonAccept;
    UIButton *buttonDecline;
    UIButton *buttonIgnore;
    
    MeetUpRequest  *meetUpReq;
    
    id<MeetUpListButtonsDelegate> delegate;
}

@property (assign) id<MeetUpListButtonsDelegate> delegate;

- (void)adjustButtons:(MeetUpRequest*)meetUpReq;

@end
