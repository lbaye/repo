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

+ (void)reportContentId:(NSString*)contentId withContentType:(ReportContentType)contentType authTokenValue:(NSString*)authTokenValue authTokenKey:(NSString*)authTokenKey parentView:(UIView*)parentView
{
    _contentId = contentId;
    _authTokenValue = authTokenValue;
    _authTokenKey = authTokenKey;
    
    switch (contentType)
    {
        case ReportContentPhoto:
            _contentType = @"photo";
            break;
        
        default:
            _contentType = @"geotag";
            break;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Report this %@?", _contentType] delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:nil];
    [actionSheet showInView:parentView];
    [actionSheet release];
    
}

+ (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"acitonSheet Button index = %d", buttonIndex);
    
    if (buttonIndex) return;
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    
    [restClient reportContentId:_contentId withContentType:_contentType authTokenValue:_authTokenValue authTokenKey:_authTokenKey callBack:^(NSString *message)
    {
        if (message) [UtilityClass showAlert:@"" : message];
        
        else [UtilityClass showAlert:@"" :@"Please try again"];
        
    }];
}

@end
