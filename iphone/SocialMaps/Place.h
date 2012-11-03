//
//  Place.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject {
    
    NSString    *name;
    NSString    *description;
    NSString    *category;
    UIImage     *photo;
    float       latitude;
    float       longitude;
    NSString    *base64Image;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, retain) NSString *base64Image;

@end
