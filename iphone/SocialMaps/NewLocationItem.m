//
//  NewLocationItem.m
//  SocialMaps
//
//  Created by Arif Shakoor on 10/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "NewLocationItem.h"
#import "UITextField+Scrolling.h"
#import "UtilityClass.h"
#import "AppDelegate.h"
#import "UtilityClass.h"

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
@synthesize lblAddress;
@synthesize delegate;

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
    CGRect mapFrame = CGRectMake(0, TEXTAREA_HEIGHT+4, self.frame.size.width, self.frame.size.height-2*(TEXTAREA_HEIGHT+4));
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
    
    // Address view
    CGRect addressFrame = CGRectMake(0, self.frame.size.height-2*(TEXTAREA_HEIGHT+4), self.frame.size.width, TEXTAREA_HEIGHT);
    lblAddress = [[UILabel alloc] initWithFrame:addressFrame];
    lblAddress.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    lblAddress.textColor = [UIColor whiteColor];
    lblAddress.textAlignment = UITextAlignmentCenter;
    lblAddress.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    [self addSubview:lblAddress];
    
    // Cancel button
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelRequest:) forControlEvents:UIControlEventTouchUpInside];
    CGRect cancelFrame = CGRectMake((self.frame.size.width/2-60)/2, self.frame.size.height-2-30, 60, 30);
    cancelBtn.frame = cancelFrame;
    [self addSubview:cancelBtn];
    
    // Separator
    CGRect sepFrame = CGRectMake(self.frame.size.width/2, self.frame.size.height-35, 1, 35);
    UIImageView *sepImageView = [[UIImageView alloc] initWithFrame:sepFrame];
    sepImageView.image = [UIImage imageNamed:@"sp.png"];
    [self addSubview:sepImageView];

    // Save button
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"Ok" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [saveBtn addTarget:self action:@selector(saveRequest:) forControlEvents:UIControlEventTouchUpInside];
    CGRect saveFrame = CGRectMake((self.frame.size.width/2-60)/2+self.frame.size.width/2, self.frame.size.height-2-30, 60, 30);
    saveBtn.frame = saveFrame;
    [self addSubview:saveBtn];
    
    [self getAddress];
}

- (void) centerMap:(id) sender {
    MKCoordinateRegion mapRegion;   
    mapRegion.center = locMap.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [locMap setRegion:mapRegion animated: YES];
    [locMap setCenterCoordinate:locMap.userLocation.location.coordinate animated:YES];
    locCoord = [locMap centerCoordinate];
    [self getAddress];
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
        [self getAddress];
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

// Get address
- (void) getAddress {
    CGRect frame = CGRectMake((lblAddress.frame.size.width-24) / 2, (lblAddress.frame.size.height-24) / 2, 24, 24);
    
    lblAddress.text = @"Retrieving address ...";
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[activityView startAnimating];
    [activityView hidesWhenStopped];
	activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[lblAddress addSubview: activityView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        lblAddress.text=[UtilityClass getAddressFromLatLon:locCoord.latitude withLongitude:locCoord.longitude];
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        [activityView release];
    });
}

// Cancel button
- (void) cancelRequest:(id) sender {
    NSLog(@"NewLocationItem: cancelRequest");
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(newLocationCreated:sender:)]) {
        [self.delegate  newLocationCreated:nil sender:self];
    }
    [self removeFromSuperview];
}

// Save button
- (void) saveRequest:(id) sender {
    NSLog(@"NewLocationItem: saveRequest");
    if (txtName.text == @"" || txtName.text == nil) {
        [UtilityClass showAlert:@"SocialMaps" :@"Please enter location name"];
        return;
    }
    Geofence * newLoc = [[Geofence alloc] init];
    newLoc.name = txtName.text;
    newLoc.lat  = [NSString stringWithFormat:@"%f", locCoord.latitude];
    newLoc.lng  = [NSString stringWithFormat:@"%f", locCoord.longitude];
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(newLocationCreated:sender:)]) {
        [self.delegate  newLocationCreated:newLoc sender:self];
    }
    [self removeFromSuperview];
}

@end
