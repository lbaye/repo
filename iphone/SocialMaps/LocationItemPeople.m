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

@implementation LocationItemPeople
@synthesize userInfo;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller {
    
    cellIdent = @"peopleItem";
    UITableViewCell *cell = [super getTableViewCell:tv sender:controller];
    
    //UILabel *lblAddress  = (UILabel*) [cell viewWithTag:2002];
    UILabel *lblName     = (UILabel*) [cell viewWithTag:2003];
    //UILabel *lblDist     = (UILabel*) [cell viewWithTag:2004];
    //UIView *line         = (UIView*) [cell viewWithTag:2005];
    UITextView   *txtMsg = (UITextView*) [cell viewWithTag:2006];  
    UIImageView *regMedia = (UIImageView*) [cell viewWithTag:20012];
    UIButton *frndButton = (UIButton*) [cell viewWithTag:20016];
    UIButton *refButton = (UIButton*) [cell viewWithTag:20017];
    
    if (txtMsg == nil) {
        CGSize msgStringSize = [userInfo.statusMsg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
        CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width/2);
        
        CGFloat msgHeight = msgRows*msgStringSize.height+16;
//        CGRect msgFrame = CGRectMake(10+itemIcon.size.width+10, 
//                                     lblName.frame.origin.y+lblName.frame.size.height+5,
//                                     tv.frame.size.width/2, msgHeight);
        CGRect msgFrame = CGRectMake(80, 
                                     lblName.frame.origin.y+lblName.frame.size.height,
                                     250, 25);

        txtMsg = [[[UITextView alloc] initWithFrame:msgFrame] autorelease];
		txtMsg.tag = 2006;
		txtMsg.textColor = [UIColor whiteColor];
		txtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		txtMsg.backgroundColor = [UIColor clearColor];
		[txtMsg setTextAlignment:UITextAlignmentLeft];
        NSLog(@"people.statusMsg %@ %lf  %lf",userInfo.statusMsg, msgFrame.origin.x, msgFrame.origin.y);
        txtMsg.userInteractionEnabled = FALSE;
        [cell.contentView addSubview:txtMsg];
                
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
    if ([userInfo.regMedia isEqualToString:@"fb"]) 
    {
        NSLog(@"reg media fb %@",[UIImage imageNamed:@"icon_facebook.png"]);
        regMedia.image=[UIImage imageNamed:@"icon_facebook.png"];
    }
    else
    {
        regMedia.image=[UIImage imageNamed:@"sm_icon@2x.png"];
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
        NSLog(@"is hidden:NO userInfo.friendshipStatus %@",userInfo.friendshipStatus);
    }
    else
    {
        frndButton.hidden=YES;
        NSLog(@"is hidden:YES userInfo.friendshipStatus %@",userInfo.friendshipStatus);
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
        NSLog(@"is hidden:NO userInfo.friendshipStatus %@",userInfo.source);
    }
    else
    {
        refButton.hidden=YES;
        NSLog(@"is hidden:YES userInfo.friendshipStatus %@",userInfo.source);
        [refButton setTitle:@"Non-Friend" forState:UIControlStateNormal];
    }     
    
	// Message
    
    // Debug
//    CGRect tmp = CGRectMake(lblAddress.frame.origin.x,lblAddress.frame.origin.y,cell.frame.size.width, 37);
//    lblAddress.frame = tmp;
//    lblAddress.text = [NSString stringWithFormat:@"%@ %@",userInfo.currentLocationLat,userInfo.currentLocationLng];

	return cell;
}

@end
