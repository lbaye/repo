//
//  ResetPassword.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPassword : UIView {
    UITextField  *password;
    UITextField  *passwordNew;
    UITextField  *passwordConfirm;
    UIButton    *updateBtn;
    id          parent;
}
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UITextField *passwordNew;
@property (nonatomic, retain) UITextField *passwordConfirm;
@property (nonatomic, retain) UIButton *updateBtn;
@property (nonatomic, retain) id parent;

- (id)initWithFrame:(CGRect)frame sender:(id) sender tag:(int)tag;
@end
