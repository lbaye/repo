//
//  UserDefault.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserDefault : NSObject {

}
-(NSMutableArray *)readArrayFromUserDefaults:(NSString*)keyName;
-(NSString *)readFromUserDefaults:(NSString*)keyName;
-(void)writeToUserDefaults:(NSString *)keyName withString:(NSString *)myString;
-(void)writeArrayToUserDefaults:(NSString *)keyName withArray:(NSMutableArray *)myArray;
-(void)removeFromDefault:(NSString *)keyName;
-(NSMutableArray *)readDataFromUserDefaults:(NSString*)keyName;
-(void)writeDataToUserDefaults:(NSString *)keyName withArray:(NSMutableArray *)myArray;

@end
