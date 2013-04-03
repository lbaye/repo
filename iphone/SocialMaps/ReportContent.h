//
//  ReportContent.h
//  SocialMaps
//
//  Created by Warif Rishi on 4/3/13.
//  Copyright (c) 2013 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ReportContentPhoto,
	ReportContentGeotag
} ReportContentType;

@interface ReportContent : NSObject <UIActionSheetDelegate>

+ (void)reportContentId:(NSString*)contentId withContentType:(ReportContentType)contentType authTokenValue:(NSString*)authTokenValue authTokenKey:(NSString*)authTokenKey parentView:(UIView*)parentView;

@end
