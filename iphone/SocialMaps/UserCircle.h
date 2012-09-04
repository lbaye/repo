//
//  UserCircle.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/18/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _CIRCLE_TYPE {
    CircleTypeSystem = 0,
    CircleTypeSecondDegree,
    CircleTypeCustom
} CIRCLE_TYPE;

@interface UserCircle : NSObject {
    NSString       *circleName;
    NSString       *circleID;
    CIRCLE_TYPE     type;
    NSMutableArray  *friends;
}

@property (nonatomic, retain) NSString * circleName;
@property(nonatomic,retain) NSString       *circleID;
@property (atomic) CIRCLE_TYPE type;
@property (nonatomic, retain) NSMutableArray * friends;

@end
