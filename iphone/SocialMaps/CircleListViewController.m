//
//  CircleListViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 6/20/13.
//  Copyright (c) 2013 Genweb2. All rights reserved.
//

#import "CircleListViewController.h"

@interface CircleListViewController ()

@end

@implementation CircleListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showOnMap:(LocationItem *)item
{
    [self.presentingViewController performSelector:@selector(showAnnotationDetailView:) withObject:item afterDelay:.8];
    [self.presentingViewController performSelector:@selector(removeCircleView:) withObject:nil afterDelay:.3];
    [self dismissModalViewControllerAnimated:YES];
}

@end
