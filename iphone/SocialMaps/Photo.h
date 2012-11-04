//
//  Photo.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geolocation.h"

@interface Photo : NSObject
{
    NSString *photoId;
    NSString *image;
    Geolocation *location;
    NSString *comment;
    NSString *imageUrl;
    NSString *address;
    NSString *title;
    NSString *description;
    UIImage *photoImage;
    NSString *permission;
    NSMutableArray *permittedUsers;
    NSMutableArray *permittedCircles;

}

@property(nonatomic,retain) NSString *photoId;
@property(nonatomic,retain) NSString *image;
@property(nonatomic,retain) Geolocation *location;
@property(nonatomic,retain) NSString *comment;
@property(nonatomic,retain) NSString *imageUrl;
@property(nonatomic,retain) NSString *address;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) UIImage *photoImage;
@property(nonatomic,retain) NSString *permission;
@property(nonatomic,retain) NSMutableArray *permittedUsers;
@property(nonatomic,retain) NSMutableArray *permittedCircles;

@end
