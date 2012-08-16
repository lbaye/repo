//
//  PersonalInformation.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PersonalInformation.h"
#import "CustomAlert.h"
#import "PhotoPicker.h"
#import "AppDelegate.h"

#define BUTTON_WIDTH 60
#define BUTTON_HEIGHT 30
#define TEXT_HEIGHT 37
#define TEXT_WIDTH  200
#define LABEL_WIDTH 90
#define LABEL_HEIGHT 37
#define PIC_WIDTH    66
#define PIC_HEIGHT   63
#define ICON_WIDTH    30
#define ICON_HEIGHT   30
#define DATE_WIDTH   100
#define GENDER_WIDTH   100


@implementation PersonalInformation

@synthesize email;
@synthesize password;
@synthesize gender;
@synthesize firstName;
@synthesize lastName;
@synthesize userName;
@synthesize dobText;
@synthesize dateOfBirth;
@synthesize bio;
@synthesize streetAddress;
@synthesize city;
@synthesize zipCode;
@synthesize country;
@synthesize service;
@synthesize relationshipStatus;
@synthesize submitBtn;
@synthesize parent;
@synthesize picBtn;
@synthesize selGender;
@synthesize photoPicker;
@synthesize userOption;
@synthesize picSel;
@synthesize calView;
@synthesize datePickerView;
@synthesize genderBtn;
@synthesize selMaleFemale;
@synthesize arrayGender;

- (id)initWithFrame:(CGRect)frame sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.parent = sender;
        self.tag    = tag;
        self.backgroundColor = [UIColor clearColor];
        CGRect viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
                                      self.frame.size.width, PIC_HEIGHT + 15 +  BUTTON_HEIGHT + 13*(5+TEXT_HEIGHT));
        self.frame = viewFrame;
        
        self.selGender = [[UIPickerView alloc] init];
        //self.selGender.delegate = self;
        
        self.photoPicker = [[PhotoPicker alloc] initWithNibName:nil bundle:nil];
        self.photoPicker.delegate = self;
        
        self.picSel = [[UIImagePickerController alloc] init];
        self.picSel.allowsEditing = YES;
        
        arrayGender = [[NSMutableArray alloc] init];
        [arrayGender addObject:@"Female"];
        [arrayGender addObject:@"Male"];
    }
    return self;
}

- (UITextField*) getTextField:(CGRect)frame text:(NSString*)txt
                          tag:(int)tag {
    UITextField *txtField = [[UITextField alloc] initWithFrame:frame];
    txtField.placeholder = txt;
    txtField.backgroundColor = [UIColor clearColor];
    txtField.textColor = [UIColor blackColor];
    txtField.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    txtField.borderStyle = UITextBorderStyleRoundedRect;
    txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtField.returnKeyType = UIReturnKeyNext;
    txtField.textAlignment = UITextAlignmentLeft;
    txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtField.tag = tag;
    txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    return txtField;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//btn_update_dark.png
- (void)drawRect:(CGRect)rect
{
    // Drawing code 
    // Profile pic
    int heightOffset = 5;
    CGRect itemFrame = CGRectMake(10, heightOffset, PIC_WIDTH, PIC_HEIGHT);
    picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    picBtn.frame = itemFrame;
    [picBtn addTarget:self 
                  action:@selector(picButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    [picBtn setImage:[UIImage imageNamed:@"thum.png"]
               forState:UIControlStateNormal];
    [self addSubview:picBtn];

    itemFrame = CGRectMake(10+PIC_WIDTH+20, 5+(PIC_HEIGHT-40)/2, 1, 40);
    UIImageView *lineSep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sp.png"]];
    lineSep.frame = itemFrame;
    [self addSubview:lineSep];

    itemFrame = CGRectMake(10+PIC_WIDTH+20+20, 5+(PIC_HEIGHT-TEXT_HEIGHT)/2, TEXT_WIDTH, TEXT_HEIGHT);
    UILabel *lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Choose a profile picture...";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    [self addSubview:lbl];
    [lbl release];
    heightOffset += PIC_HEIGHT + 5;

    // Email Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Email";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Email text
    int currTag = 100;
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    email = [self getTextField:itemFrame text:@"Email..." tag:currTag++];
    email.delegate = parent;
    [self addSubview:email];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Gender Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Gender";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Gender text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, GENDER_WIDTH, TEXT_HEIGHT);
    gender = [self getTextField:itemFrame text:@"Gender..." tag:currTag++];
    gender.delegate = parent;
    gender.userInteractionEnabled = FALSE;
    [self addSubview:gender];
    
    // Gender button
    itemFrame = CGRectMake(10+5+LABEL_WIDTH+5+GENDER_WIDTH-ICON_WIDTH, heightOffset, ICON_WIDTH, ICON_HEIGHT);
    genderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    genderBtn.frame = itemFrame;
    [genderBtn addTarget:self 
                    action:@selector(selectGender:)
          forControlEvents:UIControlEventTouchUpInside];
    [genderBtn setImage:[UIImage imageNamed:@"down_arrow.png"] forState:UIControlStateNormal];
    [self addSubview:genderBtn];
    heightOffset += TEXT_HEIGHT + 5;

    // First name Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"First name";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // First name text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    firstName = [self getTextField:itemFrame text:@"First name..." tag:currTag++];
    firstName.delegate = parent;
    [self addSubview:firstName];
    heightOffset += TEXT_HEIGHT + 5;

    // Last name Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Last name";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Last name text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    lastName = [self getTextField:itemFrame text:@"Last name..." tag:currTag++];
    lastName.delegate = parent;
    [self addSubview:lastName];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Username Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Username";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Username text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    userName = [self getTextField:itemFrame text:@"Username..." tag:currTag++];
    userName.delegate = parent;
    [self addSubview:userName];
    heightOffset += TEXT_HEIGHT + 5;

    // DOB Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Date of birth";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // DOB text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, DATE_WIDTH, TEXT_HEIGHT);
    dobText = [self getTextField:itemFrame text:@"mm/dd/yyyy" tag:currTag++];
    dobText.delegate = parent;
    [self addSubview:dobText];
    
    // DOB calander button
    itemFrame = CGRectMake(10+5+LABEL_WIDTH+5+DATE_WIDTH, heightOffset, ICON_WIDTH, ICON_HEIGHT);
    dateOfBirth = [UIButton buttonWithType:UIButtonTypeCustom];
    dateOfBirth.frame = itemFrame;
    [dateOfBirth addTarget:self 
                 action:@selector(selectDate:)
       forControlEvents:UIControlEventTouchUpInside];
    [dateOfBirth setImage:[UIImage imageNamed:@"cal-48x48.png"] forState:UIControlStateNormal];
    [self addSubview:dateOfBirth];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Bio Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Biography";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Bio text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    bio = [self getTextField:itemFrame text:@"Biography..." tag:currTag++];
    bio.delegate = parent;
    [self addSubview:bio];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Street address Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Street address";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Street address text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    streetAddress = [self getTextField:itemFrame text:@"Street address..." tag:currTag++];
    streetAddress.delegate = parent;
    [self addSubview:streetAddress];
    heightOffset += TEXT_HEIGHT + 5;

    // City Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"City";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // City text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    city = [self getTextField:itemFrame text:@"City..." tag:currTag++];
    city.delegate = parent;
    [self addSubview:city];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Zip Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Zip code";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Zip text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    zipCode = [self getTextField:itemFrame text:@"Zip code..." tag:currTag++];
    zipCode.delegate = parent;
    [self addSubview:zipCode];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Country Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Country";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Country text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    country = [self getTextField:itemFrame text:@"Country..." tag:currTag++];
    country.delegate = parent;
    [self addSubview:country];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Service Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Service";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Service text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    email = [self getTextField:itemFrame text:@"Service..." tag:currTag++];
    email.delegate = parent;
    [self addSubview:email];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Relationship Label
    itemFrame = CGRectMake(10, heightOffset, LABEL_WIDTH, LABEL_HEIGHT);
    lbl = [[UILabel alloc] initWithFrame:itemFrame];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = @"Relationship status";
    lbl.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    [self addSubview:lbl];
    [lbl release];
    
    // Relationship text
    itemFrame = CGRectMake(10+5+LABEL_WIDTH, heightOffset, TEXT_WIDTH, TEXT_HEIGHT);
    service = [self getTextField:itemFrame text:@"Relationship status..." tag:currTag++];
    service.delegate = parent;
    [self addSubview:service];
    heightOffset += TEXT_HEIGHT + 5;
    
    // Submit button
    itemFrame = CGRectMake((self.frame.size.width-BUTTON_WIDTH)/2, 
                           heightOffset, BUTTON_WIDTH, BUTTON_HEIGHT);
    submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = itemFrame;
    [submitBtn addTarget:self 
                  action:@selector(submitButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setImage:[UIImage imageNamed:@"btn_submit_dark.png"]
               forState:UIControlStateNormal];
    [self addSubview:submitBtn];
 }

- (void) submitButtonClicked:(id)sender {
    NSLog(@"PersonalInformation:submitButtonClicked called");
}

- (void) picButtonClicked:(id)sender {
    [photoPicker getPhoto:self];
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img {
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (status == TRUE) {
        [picBtn setImage:img
                   forState:UIControlStateNormal];
    } 
    [photoPicker.view removeFromSuperview];
}

// Select gender
- (void) selectGender: (id) sender {
    CGRect pickerFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 260);
    selMaleFemale = [[UIPickerView alloc] initWithFrame:pickerFrame];
    selMaleFemale.delegate = self;
    [selMaleFemale setShowsSelectionIndicator:TRUE];
    [self addSubview:selMaleFemale];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrayGender count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrayGender objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected Gender: %@. Index of selected color: %i", [arrayGender objectAtIndex:row], row);
    [selMaleFemale removeFromSuperview];
    gender.text = [arrayGender objectAtIndex:row];
}

// Date picker
- (void) selectDate: (id) sender{
	[self createDatePicker];
}

- (void)createDatePicker{
    // Add the picker
    CGRect calFrame = CGRectMake(0, 0, self.frame.size.width, 260);
    calView = [[UIView alloc] initWithFrame:calFrame];
    calView.backgroundColor = [UIColor lightGrayColor];
    
    datePickerView = [[UIDatePicker alloc] init];
    datePickerView.datePickerMode = UIDatePickerModeDate;
	datePickerView.frame = CGRectMake(0, 50, 320, 260);
	
	[calView addSubview:datePickerView];
    
    // Select button
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(20, 10, 70, 30);
    [selectBtn addTarget:self 
                    action:@selector(changeDate:)
          forControlEvents:UIControlEventTouchUpInside];
    [selectBtn setImage:[UIImage imageNamed:@"accept_button_a.png"] forState:UIControlStateNormal];
    [calView addSubview:selectBtn];
    
    // Cancel button
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(320-20-70, 10, 70, 30);
    [cancelBtn addTarget:self 
                    action:@selector(cancelDate:)
          forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:[UIImage imageNamed:@"btn_cancel_dark.png"] forState:UIControlStateNormal];
    [calView addSubview:cancelBtn];
    
    [self addSubview:calView];
    [datePickerView release];
}


- (void) changeDate:(id)sender
{
	// the select button was clicked, handle it here
	//
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSString *newDate = [dateFormatter stringFromDate:[datePickerView date]];
   
    dobText.text = newDate;
	[self cancelDate:sender];
}

- (void) cancelDate:(id)sender
{
	// the cancel button was clicked, handle it here
	//
	[calView removeFromSuperview];
}
@end
