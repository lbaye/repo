//
//  SelectCircleTableCell.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/17/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file SelectCircleTableCell.h
 * @brief Custom table cell for selection of circles.
 */

#import <UIKit/UIKit.h>

@interface SelectCircleTableCell : UITableViewCell
{
    IBOutlet UILabel *circrcleName;
    IBOutlet UIButton *circrcleCheckbox;    
}

@property(nonatomic,retain) IBOutlet UILabel *circrcleName;
@property(nonatomic,retain) IBOutlet UIButton *circrcleCheckbox;    

@end
