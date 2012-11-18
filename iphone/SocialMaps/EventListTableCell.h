//
//  EventListTableCell.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListTableCell : UITableViewCell
{
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDate;
    IBOutlet UILabel *eventAddress;
    IBOutlet UILabel *eventDistance;
    IBOutlet UILabel *eventDetail;
    IBOutlet UIButton *viewEventOnMap;
    IBOutlet UIImageView *eventImage;
    IBOutlet UIView *footerView;
    IBOutlet UIScrollView *eventNameScrollView;
    IBOutlet UIScrollView *eventAddressScrollView;
}

@property(nonatomic,retain)IBOutlet UILabel *eventName;
@property(nonatomic,retain)IBOutlet UILabel *eventDate;
@property(nonatomic,retain)IBOutlet UILabel *eventAddress;
@property(nonatomic,retain)IBOutlet UILabel *eventDistance;
@property(nonatomic,retain)IBOutlet UILabel *eventDetail;
@property(nonatomic,retain)IBOutlet UIButton *viewEventOnMap;
@property(nonatomic,retain)IBOutlet UIImageView *eventImage;
@property(nonatomic,retain)IBOutlet UIView *footerView;
@property(nonatomic,retain)IBOutlet UIScrollView *eventNameScrollView;
@property(nonatomic,retain)IBOutlet UIScrollView *eventAddressScrollView;


@end
