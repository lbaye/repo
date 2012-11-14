
#import <Foundation/Foundation.h>

@protocol SectionHeaderViewDelegate;


@interface SectionHeaderView : UIView 

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *disclosureButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, retain) id <SectionHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate;
-(void)toggleOpenWithUserAction:(BOOL)userAction;
-(IBAction)deleteButtonAction:(id)sender;
-(IBAction)renameButtonAction:(id)sender;

@end



/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol SectionHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)section;
-(void)renameCircle:(int)index;
-(void)deleteCircle:(int)index;

@end

