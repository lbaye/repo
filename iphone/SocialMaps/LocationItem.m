//
//  LocationItems.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

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
    CGSize addressStringSize = [itemAddress sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    
	CGRect CellFrame   = CGRectMake(0, 0, tv.frame.size.width, [self getRowHeight:tv]);
    CGRect addressFrame = CGRectMake(10, CellFrame.size.height-10-addressStringSize.height, addressStringSize.width, addressStringSize.height);
	CGRect distFrame = CGRectMake(CellFrame.size.width-60, CellFrame.size.height-10-addressStringSize.height, 60, addressStringSize.height);

    CGRect iconFrame = CGRectMake(10, (CellFrame.size.height/2-addressFrame.size.height-10)/2, CellFrame.size.height/2, CellFrame.size.height/2);

	CGRect nameFrame = CGRectMake(iconFrame.size.width+10, CellFrame.size.height/3, nameStringSize.width, nameStringSize.height);
    
    tv.backgroundColor = [UIColor clearColor];
	tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	//UILabel *lblCust;
	UILabel *lblName;
	UILabel *lblAddress;
    UILabel *lblDist;
    UIImageView *imgIcon;
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
        
		// Address
		lblAddress = [[[UILabel alloc] initWithFrame:addressFrame] autorelease];
		lblAddress.tag = 2002;
		lblAddress.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		lblAddress.textColor = [UIColor whiteColor];
		lblAddress.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblAddress];
        
        // Name
		lblName = [[[UILabel alloc] initWithFrame:nameFrame] autorelease];
		lblName.tag = 2003;
        lblName.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		lblName.textColor = [UIColor whiteColor];
		lblName.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblName];
		
		// Distance
		lblDist = [[[UILabel alloc] initWithFrame:distFrame] autorelease];
		lblDist.tag = 2004;
        lblDist.textAlignment = UITextAlignmentRight;
        lblDist.textColor = [UIColor whiteColor];
		lblDist.font = [UIFont fontWithName:@"Helvetica-Bold-Oblique" size:kSmallLabelFontSize];
		lblDist.textColor = [UIColor whiteColor];
		lblDist.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblDist];
		        
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
	}
    
    // Name
    lblName.frame = nameFrame;
	lblName.text = itemName;
    
    // Address
    lblAddress.frame = addressFrame;
    lblAddress.text  = itemAddress;
	
    // Distance
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
@end
