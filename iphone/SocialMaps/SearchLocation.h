//
//  SearchLocation.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/16/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchLocation : NSObject
{
    NSMutableArray *peopleArr;
    NSMutableArray *placeArr;    
}

@property(nonatomic,retain) NSMutableArray *peopleArr;
@property(nonatomic,retain) NSMutableArray *placeArr;    

@end
