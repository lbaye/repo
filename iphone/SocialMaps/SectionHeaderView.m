
#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewCircleWisePeopleViewController.h"
#import "Globals.h"
#import "UserCircle.h"

@implementation SectionHeaderView


@synthesize titleLabel=_titleLabel, disclosureButton=_disclosureButton, delegate=_delegate;
@synthesize section=_section;
ViewCircleWisePeopleViewController *circleView;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}


-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        // Set up the tap gesture recognizer.

        _delegate = delegate;        
        self.userInteractionEnabled = YES;
        
        circleView = [[ViewCircleWisePeopleViewController alloc] init];
        // Create and configure the title label.
        _section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 10.0;
        titleLabelFrame.size.width -= 150.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        NSLog(@"frame %@",NSStringFromCGRect(titleLabelFrame));
        UILabel *label = [[UILabel alloc] initWithFrame:titleLabelFrame];
        label.text = title;
        label.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        label.textColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        UIView *view=[[UIView alloc] initWithFrame:self.frame];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [view addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        [self addSubview:view];
        [view release];
        _titleLabel = label;
        
       
        
        // Create and configure the disclosure button.
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(280.0, 5.0, 35.0, 35.0);
        [button setImage:[UIImage imageNamed:@"icon_arrow_right.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        _disclosureButton = button;
        
        
        //add edit and rename button
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(180.0, 10.0, 50.0, 26.0);
        deleteButton.layer.cornerRadius=5.0;
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal] ;
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        deleteButton.tag=sectionNumber;
        [deleteButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        UIButton *renameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        renameButton.frame = CGRectMake(235, 10.0, 50.0, 26.0);
        renameButton.layer.cornerRadius=5.0;
        [renameButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal] ;
        [renameButton setTitle:@"Rename" forState:UIControlStateNormal];
        renameButton.tag=sectionNumber;
        [renameButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [renameButton addTarget:self action:@selector(renameButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [renameButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        if (((UserCircle *)[circleListDetailGlobalArray objectAtIndex:sectionNumber]).type>1)
        {
            [self addSubview:deleteButton];
            [self addSubview:renameButton];            
        }
        //finish edit and rename button
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_settings_list_bg.png"]]];
    }
    
    return self;
}


-(IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}

-(IBAction)deleteButtonAction:(id)sender
{
    [self.delegate deleteCircle:[sender tag]];
    NSLog(@"[sender tag] %d",[sender tag]);
}

-(IBAction)renameButtonAction:(id)sender
{
    [self.delegate renameCircle:[sender tag]];
    NSLog(@"[sender tag] %d",[sender tag]);    
}

-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // Toggle the disclosure button state.
    self.disclosureButton.selected = !self.disclosureButton.selected;
    
    // If this was a user action, send the delegate the appropriate message.
    if (userAction)
    {
        if (self.disclosureButton.selected)
        {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)])
            {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)])
            {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}




@end
