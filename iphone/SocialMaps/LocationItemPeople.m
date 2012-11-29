//
//  LocationItemPeople.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LocationItemPeople.h"
#import "Constants.h"
#import "UtilityClass.h"

@implementation LocationItemPeople
@synthesize userInfo;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller {
    
    cellIdent = @"peopleItem";
    UITableViewCell *cell = [super getTableViewCell:tv sender:controller];
    
    UILabel *lblAddress  = (UILabel*) [cell viewWithTag:2002];
    UILabel *lblName     = (UILabel*) [cell viewWithTag:2003];
    UILabel *lblDist     = (UILabel*) [cell viewWithTag:2004];
    //UIView *line         = (UIView*) [cell viewWithTag:2005];
    UITextView   *txtMsg = (UITextView*) [cell viewWithTag:2006];
    UIImageView *regMedia = (UIImageView*) [cell viewWithTag:20012];
    UIImageView *checkinImage = (UIImageView*) [cell viewWithTag:20032];
    UIButton *frndButton = (UIButton*) [cell viewWithTag:20016];
    UIButton *refButton = (UIButton*) [cell viewWithTag:20017];
    
    if (txtMsg == nil) {
        CGSize msgStringSize = [userInfo.statusMsg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
        CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width/2);
        
        CGRect msgFrame = CGRectMake(80, 
                                     lblName.frame.origin.y+lblName.frame.size.height,
                                     250, 25);

        txtMsg = [[[UITextView alloc] initWithFrame:msgFrame] autorelease];
		txtMsg.tag = 2006;
		txtMsg.textColor = [UIColor whiteColor];
		txtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		txtMsg.backgroundColor = [UIColor clearColor];
		[txtMsg setTextAlignment:UITextAlignmentLeft];
        txtMsg.userInteractionEnabled = FALSE;
        [cell.contentView addSubview:txtMsg];
                
    }
    
    if ([userInfo.source isEqualToString:@"facebook"]) 
    {
        NSString *checkin=[NSString stringWithFormat:@"Checked-in at %@ %@",[[userInfo.lastSeenAt componentsSeparatedByString:@","] objectAtIndex:0],[UtilityClass getCurrentTimeOrDate:userInfo.lastSeenAtDate]];
        lblAddress.text=checkin;
        CGSize addressStringSize = [checkin sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        lblAddress.frame=CGRectMake(2,5, addressStringSize.width, 15);
        NSLog(@"lbladress: %@", NSStringFromCGRect(lblAddress.frame));
        UIScrollView *addScr = (UIScrollView*) [cell viewWithTag:20031];
        [addScr setContentSize:lblAddress.frame.size];
    }
    
    if (userInfo.statusMsg) 
    {
        txtMsg.text = userInfo.statusMsg;
    }
    else
    {
        txtMsg.text=@"";
    }

    
    if (regMedia==nil) 
    {
        regMedia=[[UIImageView alloc] initWithFrame:CGRectMake(85,20,20,20)];
        regMedia.layer.borderColor=[[UIColor lightTextColor] CGColor];
        regMedia.userInteractionEnabled=YES;
        regMedia.layer.borderWidth=1.0;
        regMedia.layer.masksToBounds = YES;
        [regMedia.layer setCornerRadius:5.0];
        regMedia.tag=20012;
        [cell.contentView addSubview:regMedia];
    }
    
    if (checkinImage==nil) 
    {
        checkinImage=[[UIImageView alloc] initWithFrame:CGRectMake(110,20,20,20)];
        checkinImage.tag=20032;
        [cell.contentView addSubview:checkinImage];
    }
    
    if ([userInfo.regMedia isEqualToString:@"fb"]) 
    {
        regMedia.image = [UIImage imageNamed:@"icon_facebook.png"];
        checkinImage.image = [UIImage imageNamed:@"blank.png"];
    }
    else if ([userInfo.source isEqualToString:@"facebook"])
    {
        regMedia.image = [UIImage imageNamed:@"icon_facebook.png"];
        checkinImage.image = [UIImage imageNamed:@"fbCheckinIcon.png"];
        checkinImage.userInteractionEnabled=YES;
        checkinImage.layer.masksToBounds = YES;
        [checkinImage.layer setCornerRadius:5.0];
    }
    else
    {
        regMedia.image=[UIImage imageNamed:@"sm_icon@2x.png"];
        checkinImage.image = [UIImage imageNamed:@"blank.png"];
    }
    
    if (frndButton==nil) 
    {
        frndButton=[UIButton buttonWithType:UIButtonTypeCustom];
        frndButton.frame= CGRectMake(40,66,35,20);
        frndButton.layer.borderColor=[[UIColor lightTextColor] CGColor];
        frndButton.userInteractionEnabled=NO;
        frndButton.layer.borderWidth=1.0;
        frndButton.layer.masksToBounds = YES;
        [frndButton.layer setCornerRadius:5.0];
        [frndButton setBackgroundImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        [frndButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [frndButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        frndButton.tag=20016;
        
        
        [cell.contentView addSubview:frndButton];
    }
    if ([userInfo.friendshipStatus isEqualToString:@"friend"]==TRUE)
    {
        frndButton.hidden=NO;
        [frndButton setTitle:@"friend" forState:UIControlStateNormal];
    }
    else
    {
        frndButton.hidden=YES;
        [frndButton setTitle:@"Non-Friend" forState:UIControlStateNormal];
    }
    
    if (refButton==nil) 
    {
        refButton=[UIButton buttonWithType:UIButtonTypeCustom];
        refButton.frame= CGRectMake(40,66,45,20);
        refButton.layer.borderColor=[[UIColor lightTextColor] CGColor];
        refButton.userInteractionEnabled=NO;
        refButton.layer.borderWidth=1.0;
        refButton.layer.masksToBounds = YES;
        [refButton.layer setCornerRadius:5.0];
        [refButton setBackgroundImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        [refButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [refButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        refButton.tag=20017;
        
        
        [cell.contentView addSubview:refButton];
    }
    if ([userInfo.source isEqualToString:@"facebook"]==TRUE)
    {
        refButton.hidden=NO;
        [refButton setTitle:@"FB friend" forState:UIControlStateNormal];
    }
    else
    {
        refButton.hidden=YES;
        [refButton setTitle:@"Non-Friend" forState:UIControlStateNormal];
    }     
    
	// Message
    
    // Debug
//    CGRect tmp = CGRectMake(lblAddress.frame.origin.x,lblAddress.frame.origin.y,cell.frame.size.width, 37);
//    lblAddress.frame = tmp;
//    lblAddress.text = [NSString stringWithFormat:@"%@ %@",userInfo.currentLocationLat,userInfo.currentLocationLng];

    Geolocation *geoLocation=[[Geolocation alloc] init];
    geoLocation.latitude=userInfo.currentLocationLat;
    geoLocation.longitude=userInfo.currentLocationLng;
    lblDist.text=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
    
	return cell;
}

@end
