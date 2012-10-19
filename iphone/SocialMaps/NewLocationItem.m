//
//  NewLocationItem.m
//  SocialMaps
//
//  Created by Arif Shakoor on 10/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "NewLocationItem.h"
#import "UITextField+Scrolling.h"
#define METERS_PER_MILE 1609.344

@implementation NewLocationItem
@synthesize titleString;
@synthesize txtName;
@synthesize lblTitle;
@synthesize locMap;
@synthesize btnTag;
@synthesize parent;
@synthesize locCoord;
@synthesize locationName;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr sender:(id) sender tag:(int)tag {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        parent = sender;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views 
{
    for (MKAnnotationView *view in views) 
    {
        view.hidden = TRUE;
    }
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor lightGrayColor]; 
    
    // Text
    CGRect textFrame = CGRectMake(self.frame.size.width-TEXTAREA_WIDTH-5, 2, TEXTAREA_WIDTH, TEXTAREA_HEIGHT);
    txtName = [[UITextField alloc] initWithFrame:textFrame];
    txtName.placeholder = @"Name of location...";
    txtName.backgroundColor = [UIColor clearColor];
    txtName.textColor = [UIColor blackColor];
    txtName.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    txtName.borderStyle = UITextBorderStyleRoundedRect;
    txtName.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtName.returnKeyType = UIReturnKeyDone;
    txtName.textAlignment = UITextAlignmentLeft;
    txtName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    txtName.delegate = self;
    //btn.tag = btnTag;
    self.tag = btnTag;
    
    [self addSubview:txtName];
    
    // Title
    CGSize titleStringSize = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
    
    CGRect titleFrame = CGRectMake(2, 2+(TEXTAREA_HEIGHT-titleStringSize.height)/2, titleStringSize.width, titleStringSize.height);
    lblTitle = [[UILabel alloc] initWithFrame:titleFrame];
    lblTitle.text = titleString;
    lblTitle.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor blackColor];
    [self addSubview:lblTitle];
    
    // Mapview
    CGRect mapFrame = CGRectMake(0, TEXTAREA_HEIGHT+4, 320, self.frame.size.height-TEXTAREA_HEIGHT-4);
    locMap = [[MKMapView alloc] initWithFrame:mapFrame];
    locMap.showsUserLocation=YES;
    locMap.delegate = (id) self;
    
    MKCoordinateRegion mapRegion;   
    mapRegion.center = locMap.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [locMap setRegion:mapRegion animated: YES];
    [locMap setCenterCoordinate:locMap.userLocation.location.coordinate animated:YES];
    
    [self addSubview:locMap];
    
    // Map drag handler
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:(id) self];
    [locMap addGestureRecognizer:panRec];
    
    // Location update button
    UIButton *centerMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerMapBtn.frame = CGRectMake((locMap.frame.size.width-25)/2, 
                                    (locMap.frame.size.height-24)/2, 25, 24);
    [centerMapBtn setImage:[UIImage imageNamed:@"map_geoloc_icon.png"] forState:UIControlStateNormal];
    [centerMapBtn addTarget:self action:@selector(centerMap:) forControlEvents:UIControlEventTouchUpInside];
    [locMap addSubview:centerMapBtn];

    // Set initial location coordinate
    locCoord = [locMap centerCoordinate];
    locationName = @"";
}

- (void) centerMap:(id) sender {
    MKCoordinateRegion mapRegion;   
    mapRegion.center = locMap.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [locMap setRegion:mapRegion animated: YES];
    [locMap setCenterCoordinate:locMap.userLocation.location.coordinate animated:YES];
    [locMap setNeedsDisplay];
}

// Gesture recognizer for map drag event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        locCoord = [locMap centerCoordinate];
        NSLog(@"Map drag ended, lat=%f, lng=%f", locCoord.latitude, locCoord.longitude);
        txtName.text = [NSString stringWithFormat:@"lat=%f, lng=%f", locCoord.latitude, locCoord.longitude];
    }
}

//
// UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    [self endEditing:YES];
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField animateTextField: textField up: NO];
    // Store the new location name
    locationName = textField.text;
}
@end
