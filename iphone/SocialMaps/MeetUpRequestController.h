//
//  MeetUpRequestController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>

@interface MeetUpRequestController : UIViewController <CustomRadioButtonDelegate, UIScrollViewDelegate, MKMapViewDelegate> {
    
    IBOutlet UILabel *labelAddress;
    //friends list code
    IBOutlet UIScrollView *frndListScrollView;
    IBOutlet UISearchBar  *friendSearchbar;
    IBOutlet MKMapView *pointOnMapView;
    
    NSMutableArray *selectedFriendsIndex;
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    CGFloat animatedDistance;
    NSMutableDictionary *dicImages_msg;
    NSMutableArray *ImgesName;
}


- (IBAction)actionBackMe:(id)sender;

@end
