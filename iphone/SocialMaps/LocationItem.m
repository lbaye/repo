//
//  LocationItems.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ListViewController.h"
#import "LocationItem.h"
#import "Constants.h"
#import "UIImageView+roundedCorner.h"

@implementation LocationItem
@synthesize itemName;
@synthesize itemAddress;
@synthesize itemCategory;
@synthesize itemType;
@synthesize coordinate;
@synthesize itemIcon;
@synthesize itemBg;
@synthesize itemDistance;
@synthesize cellIdent;
@synthesize currDisplayState;
@synthesize delegate;

- (id)initWithName:(NSString*)name address:(NSString*)address type:(OBJECT_TYPES)type
          category:(NSString*)category coordinate:(CLLocationCoordinate2D)coord dist:(float)dist icon:(UIImage*)icon bg:(UIImage*)bg{
    if ((self = [super init])) {
        itemName = [name copy];
        itemAddress = [address copy];
        itemType = type;
        itemCategory = category;
        coordinate = coord;
        itemDistance = dist;
        itemIcon = icon;
        itemBg = bg;
        currDisplayState = MapAnnotationStateNormal;
    }
    return self;
}

- (NSComparisonResult) compareDistance:(LocationItem*) other {
    if (self.itemDistance < other.itemDistance)
        return NSOrderedAscending;
    else if (self.itemDistance > other.itemDistance)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller {
    CGSize nameStringSize = [itemName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize addressStringSize = [itemAddress sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    
	CGRect CellFrame   = CGRectMake(0, 0, tv.frame.size.width, [self getRowHeight:tv]);
    
    // A container to hold address, maplink and distance
    CGRect footerFrame  = CGRectMake(10, CellFrame.size.height-30, tv.frame.size.width-20, 25);
    
    CGRect scrollFrame = CGRectMake(0, 0, 
                                    footerFrame.size.width-20-100, footerFrame.size.height);
    CGRect addressFrame = CGRectMake(2, (scrollFrame.size.height-addressStringSize.height)/2, 
                                    addressStringSize.width, addressStringSize.height);
    CGRect mapFrame = CGRectMake(footerFrame.size.width-72-25, (footerFrame.size.height-25)/2, 25, 25);
	CGRect distFrame = CGRectMake(footerFrame.size.width-72, (footerFrame.size.height-15)/2, 70, 15);

    CGRect iconFrame = CGRectMake(10, (CellFrame.size.height/2-addressFrame.size.height-10)/2, CellFrame.size.height/2, CellFrame.size.height/2);

	CGRect nameFrame = CGRectMake(10+iconFrame.size.width+10, CellFrame.size.height/3, nameStringSize.width, nameStringSize.height);
    
    tv.backgroundColor = [UIColor clearColor];
	tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	//UILabel *lblCust;
	UILabel *lblName;
	UILabel *lblAddress;
    UIScrollView *scrollAddress;
    UILabel *lblDist;
    UIView  *footerView;
    UIImageView *imgIcon;
    UIButton    *btnMap;
    UIImageView *mapIcon;
    UIView      *line;
    
    NSLog(@"LocationItem: cellIdent=%@", cellIdent);
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdent];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent] autorelease];
        cell.frame = CellFrame;
        // Background
        cell.backgroundView = [[[UIImageView alloc] initWithImage:itemBg] autorelease];
		cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:itemBg] autorelease];
        
        // Icon
        imgIcon = [UIImageView imageViewWithRectImage:iconFrame andImage:itemIcon withCornerradius:.10f];
        imgIcon.tag = 2010;
        imgIcon.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
        [cell.contentView addSubview:imgIcon];
        
        // Name
		lblName = [[[UILabel alloc] initWithFrame:nameFrame] autorelease];
		lblName.tag = 2003;
        lblName.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		lblName.textColor = [UIColor whiteColor];
		lblName.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblName];
		
        // Footer view
        footerView = [[UIView alloc] initWithFrame:footerFrame];
        [footerView.layer setCornerRadius:6.0f];
        [footerView.layer setMasksToBounds:YES];
        footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        [cell.contentView addSubview:footerView];
        
		// Address
        scrollAddress = [[UIScrollView alloc] initWithFrame:scrollFrame];
        CGSize addrContentsize = CGSizeMake(addressStringSize.width, scrollAddress.frame.size.height);
        scrollAddress.contentSize = addrContentsize;
        scrollAddress.tag=20031;
        scrollAddress.backgroundColor = [UIColor clearColor];
        
		lblAddress = [[[UILabel alloc] initWithFrame:addressFrame] autorelease];
		lblAddress.tag = 2002;
		lblAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
		lblAddress.textColor = [UIColor whiteColor];
		lblAddress.backgroundColor = [UIColor clearColor];
        [scrollAddress addSubview:lblAddress];
		[footerView addSubview:scrollAddress];
        
        // Map link
//        mapIcon = [UIImageView imageViewWithRectImage:mapFrame andImage:[UIImage imageNamed:@"show_on_map.png"] withCornerradius:.10f];
//        mapIcon.tag = 2011;
//        mapIcon.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
//        [footerView addSubview:mapIcon];

        btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMap.frame = mapFrame;
        btnMap.backgroundColor = [UIColor clearColor];
        [btnMap setImage:[UIImage imageNamed:@"show_on_map.png"] forState:UIControlStateNormal];
        [btnMap addTarget:self action:@selector(showInMapview:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnMap];
        
		// Distance
		lblDist = [[[UILabel alloc] initWithFrame:distFrame] autorelease];
		lblDist.tag = 2004;
        lblDist.textAlignment = UITextAlignmentRight;
        lblDist.textColor = [UIColor whiteColor];
		lblDist.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
		lblDist.textColor = [UIColor whiteColor];
		lblDist.backgroundColor = [UIColor clearColor];
		[footerView addSubview:lblDist];
		        
        // Line
        CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
        line = [[UIView alloc] initWithFrame:lineFrame];
        line.tag = 2005;
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
		
    } else {
		lblAddress  = (UILabel*) [cell viewWithTag:2002];
        lblName     = (UILabel*) [cell viewWithTag:2003];
		lblDist     = (UILabel*) [cell viewWithTag:2004];
        line        = (UIView*) [cell viewWithTag:2005];
        imgIcon     = (UIImageView*) [cell viewWithTag:2010];
        mapIcon     = (UIImageView*) [cell viewWithTag:2011];
	}
    
    // Name
    lblName.frame = nameFrame;
	lblName.text = itemName;
    
    // Address
    lblAddress.frame = addressFrame;
    lblAddress.text  = itemAddress;
	
    // Distance
    if (itemDistance > 999)
        lblDist.text = [NSString stringWithFormat:@"%.1fkm", itemDistance/1000.0];
    else
        lblDist.text = [NSString stringWithFormat:@"%dm", (int)itemDistance];
                    
    // Icon
    imgIcon.image = itemIcon;
    
	return cell;

}

- (CGFloat) getRowHeight:(UITableView*)tv {    
    return (tv.frame.size.height/3);
}

- (NSString*) getIdent {
    return @"LocationItem";
}

- (NSString *)title {
    if ([itemName isKindOfClass:[NSNull class]]) 
        return @"Unknown item";
    else
        return itemName;
}

- (NSString *)subtitle {
    return itemAddress;
}

// Button click handlers
- (int) getCellRow:(id)sender {
    UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the 
    // UIView which is the superview of UIButton
    UITableViewCell *cell = (UITableViewCell *) [[[button superview] superview] superview];
    ListViewController *listTable = (ListViewController*) delegate;
    int row = [listTable.itemList indexPathForCell:cell].row;
    return row;
}

- (void) showInMapview:(id)sender {
    NSLog(@"LocationItem:showInMapview");
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:row:)]) {
        int row = [self getCellRow:sender];
        [delegate buttonClicked:LocationActionTypeGotoMap row:row];
    }

}
@end
