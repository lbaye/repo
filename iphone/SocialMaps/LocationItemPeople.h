//
//  LocationItemPeople.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationItem.h"
#import "User.h"

@interface LocationItemPeople : LocationItem {
    User        *userInfo;
}
@property (nonatomic, retain) User    *userInfo;

@end
