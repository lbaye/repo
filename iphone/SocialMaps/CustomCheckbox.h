//
//  CustomCheckbox.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _BOX_LOCATION {
    LabelPositionLeft = 0,
    LabelPositionRight
} BOX_LOCATION;

@protocol CustomCheckboxDelegate <NSObject>

- (void) checkboxClicked:(int)indx withState:(int)clicked sender:(id)sender;

@end

@interface CustomCheckbox : UIView {
    int         numBoxes;
    NSArray     *labels;
    NSMutableArray *checkboxState;
    id<CustomCheckboxDelegate> delegate;
    BOX_LOCATION   type;
}
@property (nonatomic) int numBoxes;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSMutableArray * checkboxState;
@property (nonatomic, retain) id<CustomCheckboxDelegate> delegate;
@property (nonatomic) BOX_LOCATION type;

- (id)initWithFrame:(CGRect)frame boxLocType:(BOX_LOCATION)locType numBoxes:(int)num default:(NSArray*)def labels:(NSArray*) lbls;
- (void) setState:(int)state btnNum:(int)num;
@end
