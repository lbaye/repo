//
//  LocationSharingPref.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationSharingPref.h"
#define ROW_HEIGHT 62

@implementation LocationSharingPref
@synthesize parent;
@synthesize timeLimit;
@synthesize radius;
@synthesize permission;
@synthesize level;

- (id)initWithFrame:(CGRect)frame prefs:(int)prefs defRadius:(int) rad defDuration:(int) dur defPerm:(bool)perm sender:(id) sender tag:(int)tag
{
    return [self initWithFrame:frame prefs:prefs defRadius:rad defDuration:dur defPerm:perm sender:sender tag:tag level:0];
}

- (id)initWithFrame:(CGRect)frame prefs:(int)prefs defRadius:(int) rad defDuration:(int) dur defPerm:(bool)perm sender:(id) sender tag:(int)tag level:(int)lvl
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        parent = sender;
        self.tag = tag;
        self.backgroundColor = [UIColor clearColor];
        self.level = lvl;
        
        int prefCount = 0;
        CGRect rowFrame;
                
        if ((prefs & LocationSharingPrefTypeTime) != 0) {
            // 
            rowFrame = CGRectMake(self.frame.origin.x+level*10, ROW_HEIGHT*prefCount++, self.frame.size.width-level*10, ROW_HEIGHT);
            timeLimit = [[CounterItem alloc] initWithFrame:rowFrame title:@"Time limit of the sharing (in min):" subTitle:@"For unlimited time set to 0" defVal:dur sender:sender tag:self.tag+100];
            timeLimit.backgroundColor = [UIColor clearColor];
            [self addSubview:timeLimit];
        }
        
        if ((prefs & LocationSharingPrefTypeRadius) != 0) {
            //
            rowFrame = CGRectMake(self.frame.origin.x+level*10, ROW_HEIGHT*prefCount++, self.frame.size.width-level*10, ROW_HEIGHT);
            radius = [[CounterItem alloc] initWithFrame:rowFrame title:@"Radius for invisibility (in km):" subTitle:@"" defVal:rad sender:sender tag:self.tag+200];
            radius.backgroundColor = [UIColor clearColor];
            [self addSubview:radius];
        }
        
        if ((prefs & LocationSharingPrefTypePermission) != 0) {
            //
            rowFrame = CGRectMake(self.frame.origin.x+level*10, ROW_HEIGHT*prefCount++, self.frame.size.width-level*10, ROW_HEIGHT);
            permission = [[RadioButtonItem alloc] initWithFrame:rowFrame title:@"Permission needed for sharing:" subTitle:@"" labels:[NSArray arrayWithObjects:@"No", @"Yes", nil] defBtn:0 sender:self tag:self.tag+300];
            permission.backgroundColor = [UIColor clearColor];
            [self addSubview:permission];
        }
        
        // Dividers
        for (int i=1; i<prefCount; i++) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x+level*10, ROW_HEIGHT*i, self.frame.size.width-level*10, 1)];
            sep.backgroundColor = [UIColor lightGrayColor];
            [self addSubview:sep];
            [sep release];
        }
        
        CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, ROW_HEIGHT*prefCount);
        self.frame = newFrame;
    }
    return self;
}

// CustomCounterDelegate method
- (void) counterValueChanged:(int)newVal sender:(id)sender {
    
    NSLog(@"LocationSharingPref counterValueChanged new value=%d, sender tag = %d", newVal, (int) sender);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor clearColor];
}


@end
