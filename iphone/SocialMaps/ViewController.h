//
//  ViewController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginController.h"

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic,retain) IBOutlet UIView *privateBetaView; 
@property (nonatomic,retain) IBOutlet UITextField *betaPassWord;

-(IBAction)discoverApp:(id)sender;
-(IBAction)requestPassword:(id)sender;

-(IBAction)textFieldEntryDone:(id)sender;

@end
