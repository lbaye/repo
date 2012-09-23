//
//  LocationItemPlace.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationItemPlace.h"
#import "ListViewController.h"

@implementation LocationItemPlace
@synthesize catIcon;
@synthesize showReview;
//@synthesize delegate;
@synthesize placeInfo;

- (id)initWithName:(NSString*)name address:(NSString*)address type:(OBJECT_TYPES)type
          category:(NSString*)category coordinate:(CLLocationCoordinate2D)coord dist:(float)dist icon:(UIImage*)icon bg:(UIImage*)bg {
    
    if (self = [super initWithName:name address:address type:type category:category coordinate:coord dist:dist icon:icon bg:bg]) {
        
    }
    return self;
}
- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller {
    
    cellIdent = @"placeItem";
    UITableViewCell *cell = [super getTableViewCell:tv sender:controller];
    
    UILabel *lblName     = (UILabel*) [cell viewWithTag:2003];    
    UIImageView   *catImage = (UIImageView*) [cell viewWithTag:2007];  
    if (catImage == nil) {
        CGRect catImgFrame = CGRectMake(10+itemIcon.size.width+10, 
                                     cell.frame.size.height/2-28,
                                     28, 28);
        catImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_dining.png"]];
        catImage.frame = catImgFrame;
        catImage.tag   = 2007;
		
		[cell.contentView addSubview:catImage];
    }
    
    UIButton   *review = (UIButton*) [cell viewWithTag:2008];  
    if (review == nil) {
        CGRect reviewFrame = CGRectMake(cell.frame.size.width-110, 
                                        cell.frame.size.height/2-37, 100, 37);
        review = [UIButton buttonWithType:UIButtonTypeCustom];
        review.frame = reviewFrame;
        review.backgroundColor = [UIColor clearColor];

        [review setImage:[UIImage imageNamed:@"review_btn.png"] forState:UIControlStateNormal];
        [review addTarget:self 
                     action:@selector(showReview:)
           forControlEvents:UIControlEventTouchUpInside];

        catImage.tag   = 2008;
		
		[cell.contentView addSubview:review];
    }
    // TODO: Hiding review for appstore submission. revert once feature is implemented
    review.hidden = TRUE;
    
	// Name
    CGSize nameSize = [itemName sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGRect nameFrame = CGRectMake(10+itemIcon.size.width+10, 
                                  catImage.frame.origin.y+catImage.frame.size.height+5, nameSize.width, nameSize.height);
    lblName.frame = nameFrame;
    
	return cell;
}

+ (UIImage*) getIconForCategory:(NSString*)cat {
    // Decide on category icon based on passed in value
    NSString* iconPath = [[NSBundle mainBundle] pathForResource:@"category_dining" ofType:@"png"];
    UIImage *catIcon = [[UIImage alloc] initWithContentsOfFile:iconPath];
    return catIcon;
}

// Button click handlers
- (int) getCellRowForReview:(id)sender {
    UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    UITableViewCell *cell = (UITableViewCell *) [[button superview] superview];
    ListViewController *listView = (ListViewController*) delegate;
    int row = [listView.itemList indexPathForCell:cell].row;
    return row;
}

- (void) showReview:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:row:)]) {
        int row = [self getCellRowForReview:sender];
        [delegate buttonClicked:LocationActionTypePlaceReview row:row];
    }
}
@end
