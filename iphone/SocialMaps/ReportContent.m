//
//  ReportContent.m
//  SocialMaps
//
//  Created by Warif Rishi on 4/3/13.
//  Copyright (c) 2013 Genweb2. All rights reserved.
//

#import "ReportContent.h"
#import "RestClient.h"
#import "UtilityClass.h"

static NSString *_contentType;
static NSString *_contentId;
static NSString *_authTokenValue;
static NSString *_authTokenKey;

@implementation ReportContent

+ (void)reportContentId:(NSString*)contentId withContentType:(NSString*)contentType authTokenValue:(NSString*)authTokenValue authTokenKey:(NSString*)authTokenKey parentView:(UIView*)parentView title:(NSString*)title
{
    _contentId = [contentId copy];
    _authTokenValue = [authTokenValue copy];
    _authTokenKey = [authTokenKey copy];
    _contentType = [contentType copy];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:nil];
    [actionSheet showInView:parentView];
    [actionSheet release];
    
}

+ (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) return;
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    
    [restClient reportContentId:_contentId withContentType:_contentType authTokenValue:_authTokenValue authTokenKey:_authTokenKey callBack:^(NSString *message)
    {
        //Report sent!
        if (message) [UtilityClass showAlert:@"" : message];
        
        else [UtilityClass showAlert:@"" :@"Report not sent, try again!"];
        
        [_contentType release];
        [_contentId release];
        [_authTokenValue release];
        [_authTokenKey release];
        
    }];
}

@end
