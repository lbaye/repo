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
     bool facebook;
     bool fourSquare; 
     bool googlePlus; 
     bool gmail;
     bool twitter; 
     bool yahoo; 
     bool badoo;
}

@property(atomic)  bool facebook;
@property(atomic)  bool fourSquare; 
@property(atomic)  bool googlePlus; 
@property(atomic)  bool gmail;
@property(atomic)  bool twitter; 
@property(atomic)  bool yahoo; 
@property(atomic)  bool badoo;

@end
