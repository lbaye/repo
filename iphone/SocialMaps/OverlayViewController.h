//
//  OverlayViewController.h
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>

@class ListViewController;

@interface OverlayViewController : UIViewController {

	ListViewController *rvController;
}

@property (nonatomic, retain) ListViewController *rvController;

@end
