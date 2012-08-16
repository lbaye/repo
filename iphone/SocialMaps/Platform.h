//
//  Platform.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Platform : NSObject
{
     NSString *facebook;
     NSString *fourSquare; 
     NSString *googlePlus; 
     NSString *gmail;
     NSString *twitter; 
     NSString *yahoo; 
     NSString *badoo;
}

@property(nonatomic,retain)  NSString *facebook;
@property(nonatomic,retain)  NSString *fourSquare; 
@property(nonatomic,retain)  NSString *googlePlus; 
@property(nonatomic,retain)  NSString *gmail;
@property(nonatomic,retain)  NSString *twitter; 
@property(nonatomic,retain)  NSString *yahoo; 
@property(nonatomic,retain)  NSString *badoo;

@end
