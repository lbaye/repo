//
//  CircleListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 6/20/13.
//  Copyright (c) 2013 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationItem;

@interface CircleListViewController : UIViewController

- (void)showOnMap:(LocationItem *)item;

@end
