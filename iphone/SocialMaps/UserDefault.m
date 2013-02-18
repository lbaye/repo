//
//  UserDefault.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "UserDefault.h"


@implementation UserDefault


-(NSString *)readFromUserDefaults:(NSString*)keyName
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	NSString *storedLanguage = [defaults objectForKey:keyName];
	[defaults synchronize];
	
	[defaults release];
	
	return storedLanguage;	
}
-(NSMutableArray *)readArrayFromUserDefaults:(NSString*)keyName
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	NSMutableArray *storedLanguage = [defaults objectForKey:keyName];
	[defaults synchronize];
	
	[defaults release];
	
	return storedLanguage;	
}

-(NSArray *)readDataFromUserDefaults:(NSString*)keyName
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	NSData *data = [defaults objectForKey:keyName];
	NSArray *myArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [defaults synchronize];
	
	[defaults release];
	
	return myArray;	
}

-(void)writeDataToUserDefaults:(NSString *)keyName withArray:(NSMutableArray *)myArray
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:myArray];
    [defaults setObject:data forKey:keyName];
	[defaults synchronize];
	
	[defaults release];
}

-(void)writeToUserDefaults:(NSString *)keyName withString:(NSString *)myString
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	[defaults setObject:myString forKey:keyName];
	[defaults synchronize];
	
	[defaults release];
}
-(void)writeArrayToUserDefaults:(NSString *)keyName withArray:(NSMutableArray *)myArray
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	[defaults setObject:myArray forKey:keyName];
	[defaults synchronize];
	
	[defaults release];
}

-(void)removeFromDefault:(NSString *)keyName
{
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
	[defaults removeObjectForKey:keyName];
	[defaults synchronize];	
	[defaults release];
}
@end
