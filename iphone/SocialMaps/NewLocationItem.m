//
//  NewLocationItem.m
//  SocialMaps
//
//  Created by Arif Shakoor on 10/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "NewLocationItem.h"

@implementation NewLocationItem
@synthesize titleString;
@synthesize txtName;
@synthesize lblTitle;
@synthesize locMap;
@synthesize btnTag;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr sender:(id) sender tag:(int)tag {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        parent = sender;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor lightGrayColor]; 
    
    CGSize titleStringSize = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
    
    CGRect titleFrame = CGRectMake(10, (self.frame.size.height-titleStringSize.height)/2, titleStringSize.width, titleStringSize.height);
    lblTitle = [[UILabel alloc] initWithFrame:titleFrame];
    lblTitle.text = titleString;
    lblTitle.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    [self addSubview:lblTitle];
    
    // Text
    CGRect textFrame = CGRectMake(self.frame.size.width-TEXTAREA_WIDTH-5, 
                                     (self.frame.size.height-TEXTAREA_HEIGHT)/2, TEXTAREA_WIDTH, TEXTAREA_HEIGHT);
    txtName = [[UITextField alloc] initWithFrame:textFrame];
    txtName.placeholder = @"Name of location...";
    txtName.backgroundColor = [UIColor clearColor];
    txtName.textColor = [UIColor blackColor];
    txtName.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    txtName.borderStyle = UITextBorderStyleRoundedRect;
    txtName.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtName.returnKeyType = UIReturnKeyDone;
    txtName.textAlignment = UITextAlignmentLeft;
    txtName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    txtName.delegate = parent;
    //btn.tag = btnTag;
    self.tag = btnTag;
    
    [self addSubview:txtName];
    
}

@end
