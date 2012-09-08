//
//  ShowOnMapController.m
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ShowOnMapController.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "LocationItem.h"


@implementation ShowOnMapController
@synthesize mapViewLoacation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLocation:(LocationItem*)locItem

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.mapViewLoacation removeAnnotations:[self.mapViewLoacation annotations]];
        locationItem = locItem;
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CLLocationCoordinate2D theCoordinate = locationItem.coordinate;
    
    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    
    MKCoordinateRegion adjustedRegion = [self.mapViewLoacation regionThatFits:viewRegion];  
    [self.mapViewLoacation setRegion:adjustedRegion animated:YES]; 
    
    //annotation.title =[NSString stringWithFormat:@"Address: %@",locationItem.itemAddress];
    
    [self.mapViewLoacation setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapViewLoacation addAnnotation:annotation];
}

- (void)viewDidUnload
{
    [self setMapViewLoacation:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)actionBackButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [mapViewLoacation release];
    [super dealloc];
}
@end
