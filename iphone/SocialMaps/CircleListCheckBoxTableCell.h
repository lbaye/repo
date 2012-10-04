//
//  CircleListCheckBoxTableCell.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleListCheckBoxTableCell : UITableViewCell
{
IBOutlet UILabel *firstNameLabel;
IBOutlet UILabel *addressLabel;
IBOutlet UILabel *distanceLabel;
IBOutlet UIButton *inviteButton;
IBOutlet UIButton *messageButton;
IBOutlet UIButton *showOnMapButton;
IBOutlet UIButton *checkBoxButton;
IBOutlet UIImageView *profilePicImgView;
IBOutlet UIImageView *coverPicImgView;
IBOutlet UIImageView *regStsImgView;
IBOutlet UIButton *friendShipStatus;
IBOutlet UIView *footerView;
}

@property(nonatomic,retain) IBOutlet UILabel *firstNameLabel;
@property(nonatomic,retain) IBOutlet UILabel *addressLabel;
@property(nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic,retain) IBOutlet UIButton *inviteButton;
@property(nonatomic,retain) IBOutlet UIButton *messageButton;
@property(nonatomic,retain) IBOutlet UIButton *checkBoxButton;
@property(nonatomic,retain) IBOutlet UIButton *showOnMapButton;
@property(nonatomic,retain) IBOutlet UIImageView *profilePicImgView;
@property(nonatomic,retain) IBOutlet UIImageView *coverPicImgView;   
@property(nonatomic,retain) IBOutlet UIImageView *regStsImgView;
@property(nonatomic,retain) IBOutlet UIButton *friendShipStatus;
@property(nonatomic,retain) IBOutlet UIView *footerView;
@end
