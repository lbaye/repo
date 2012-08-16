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
@synthesize delegate;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller {
    
    cellIdent = @"placeItem";
    UITableViewCell *cell = [super getTableViewCell:tv sender:controller];
    
    UILabel *lblName     = (UILabel*) [cell viewWithTag:2003];    
    UIImageView   *catImage = (UIImageView*) [cell viewWithTag:2007];  
    if (catImage == nil) {
        CGRect catImgFrame = CGRectMake(10+itemIcon.size.width+10, 
                                     cell.frame.size.height/2,
                                     28, 28);
        catImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sm_icon.png"]];
        catImage.frame = catImgFrame;
        catImage.tag   = 2007;
		
		[cell.contentView addSubview:catImage];
    }
    
    UIButton   *review = (UIButton*) [cell viewWithTag:2008];  
    if (review == nil) {
        CGRect reviewFrame = CGRectMake(cell.frame.size.width-110, 
                                        cell.frame.size.height/4*3-37, 100, 37);
        review = [UIButton buttonWithType:UIButtonTypeCustom];
        review.frame = reviewFrame;
        review.backgroundColor = [UIColor clearColor];
        review.titleLabel.text = @"Show reviews";
        review.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        
        [review addTarget:self 
                     action:@selector(showReview:)
           forControlEvents:UIControlEventTouchUpInside];

        catImage.tag   = 2008;
		
		[cell.contentView addSubview:review];
    }
    
	// Name
    CGRect nameFrame = CGRectMake(10+itemIcon.size.width+10, 
                                  cell.frame.size.height/4*3-lblName.frame.size.height, lblName.frame.size.width, lblName.frame.size.height);
    lblName.frame = nameFrame;
    
	return cell;
}

// Button click handlers
- (int) getCellRow:(id)sender {
    UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    UITableViewCell *cell = (UITableViewCell *) [[button superview] superview];
    ListViewController *listView = (ListViewController*) delegate;
    int row = [listView.itemList indexPathForCell:cell].row;
    return row;
}

- (void) showReview:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(showLocationReview:)]) {
        int row = [self getCellRow:sender];
        [delegate showLocationReview:row];
    }
}
@end
