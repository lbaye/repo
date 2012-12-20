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

/**
 * @brief Navigate user to login screen
 * @param (id) - Action sender
 * @retval action
 */
-(IBAction)discoverApp:(id)sender;

/**
 * @brief Navigate user to request for beta password window
 * @param (id) - Action sender
 * @retval action
 */
-(IBAction)requestPassword:(id)sender;

/**
 * @brief Hides keyboard for beta password
 * @param (id) - Action sender
 * @retval action
 */
-(IBAction)textFieldEntryDone:(id)sender;

@end
