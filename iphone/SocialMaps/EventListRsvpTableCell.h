//
//  EventListRsvpTableCell.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/26/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

/**
 * @file EventListRsvpTableCell.h
 * @brief Custom table cell with event RSVP option.
 */

#import <UIKit/UIKit.h>

@interface EventListRsvpTableCell : UITableViewCell
{
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDate;
    IBOutlet UILabel *eventAddress;
    IBOutlet UILabel *eventDistance;
    IBOutlet UILabel *eventDetail;
    IBOutlet UIButton *viewEventOnMap;
    IBOutlet UIImageView *eventImage;
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
    IBOutlet UIButton *maybesButton;
    IBOutlet UIView *footerView;
    IBOutlet UIScrollView *eventNameScrollView;
    IBOutlet UIScrollView *eventAddressScrollView;
}

@property(nonatomic,retain)IBOutlet UIView *footerView;
@property(nonatomic,retain)IBOutlet UILabel *eventName;
@property(nonatomic,retain)IBOutlet UILabel *eventDate;
@property(nonatomic,retain)IBOutlet UILabel *eventAddress;
@property(nonatomic,retain)IBOutlet UILabel *eventDistance;
@property(nonatomic,retain)IBOutlet UILabel *eventDetail;
@property(nonatomic,retain)IBOutlet UIButton *viewEventOnMap;
@property(nonatomic,retain)IBOutlet UIImageView *eventImage;
@property(nonatomic,retain)IBOutlet UIButton *yesButton;
@property(nonatomic,retain)IBOutlet UIButton *noButton;
@property(nonatomic,retain)IBOutlet UIButton *maybesButton;
@property(nonatomic,retain) IBOutlet UIScrollView *eventNameScrollView;
@property(nonatomic,retain) IBOutlet UIScrollView *eventAddressScrollView;

@end
