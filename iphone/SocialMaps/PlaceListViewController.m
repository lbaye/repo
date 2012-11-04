//
//  PlaceListViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 11/3/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PlaceListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "RestClient.h"
#import "Constants.h"
#import "Place.h"

#define     CELL_HEIGHT             130

@implementation PlaceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPlaces:) name:NOTIF_GET_PLACES_DONE object:nil];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getPlaces:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_PLACES_DONE object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [tableViewPlaceList release];
    tableViewPlaceList = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CLLocationDistance) getDistanceFromMe:(CLLocationCoordinate2D) loc 
{
    CLLocation *myLoc = [[CLLocation alloc] initWithLatitude:[smAppDelegate.currPosition.latitude floatValue] longitude:[smAppDelegate.currPosition.longitude floatValue]];
    CLLocation *userLoc = [[CLLocation alloc] initWithCoordinate:loc altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
    CLLocationDistance distanceFromMe = [myLoc distanceFromLocation:userLoc];
    
    return distanceFromMe;
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place *place = (Place*)[placeList objectAtIndex:indexPath.row];
    
    CGSize addressStringSize = [place.address sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    CGSize nameStringSize = [place.name sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeList"];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placeList"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //Thumb Image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT)];
        imageView.tag = 3001;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.image = [UIImage imageNamed:@"cover_pic_default.png"];
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        UILabel *lblPlaceName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 25)];
        lblPlaceName.tag = 3002;
        [lblPlaceName.layer setCornerRadius:3.0f];
        [lblPlaceName.layer setMasksToBounds:YES];
        lblPlaceName.textAlignment = UITextAlignmentLeft;
        lblPlaceName.font = [UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize];
        lblPlaceName.textColor = [UIColor whiteColor];
        lblPlaceName.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
        [cell.contentView addSubview:lblPlaceName];
        [lblPlaceName release];
        
        UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.frame = CGRectMake(240, (CELL_HEIGHT - 30 - 25) / 2, 70, 30);
        btnEdit.backgroundColor  = [UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:0.8];
        [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnEdit.layer setCornerRadius:6.0f];
        [btnEdit.layer setMasksToBounds:YES];
        [btnEdit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        [btnEdit setTitle:@"Edit place" forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(actionEditPlace:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnEdit];
        
        // Footer view
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, CELL_HEIGHT - 30, 300, 25)];
        [footerView.layer setCornerRadius:6.0f];
        [footerView.layer setMasksToBounds:YES];
        footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        [cell.contentView addSubview:footerView];
        
		// Address
        UIScrollView *scrollAddress = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 180, 25)];
        scrollAddress.tag = 3003;
        scrollAddress.backgroundColor = [UIColor clearColor];
        
		UILabel *lblAddress = [[[UILabel alloc] initWithFrame:CGRectMake(2, (scrollAddress.frame.size.height - 15) / 2, addressStringSize.width, addressStringSize.height)] autorelease];
		lblAddress.tag = 3004;
		lblAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
		lblAddress.textColor = [UIColor whiteColor];
		lblAddress.backgroundColor = [UIColor clearColor];
        [scrollAddress addSubview:lblAddress];
		[footerView addSubview:scrollAddress];
        
        UIButton *btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMap.frame = CGRectMake(203, 0, 25, 25);
        btnMap.backgroundColor = [UIColor clearColor];
        [btnMap setImage:[UIImage imageNamed:@"show_on_map.png"] forState:UIControlStateNormal];
        [btnMap addTarget:self action:@selector(showInMapview:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnMap];
        
		// Distance
		UILabel *lblDist = [[[UILabel alloc] initWithFrame:CGRectMake(228, (footerView.frame.size.height - 15) / 2, 70, 15)] autorelease];
		lblDist.tag = 3005;
        lblDist.textAlignment = UITextAlignmentRight;
        lblDist.textColor = [UIColor whiteColor];
		lblDist.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
		lblDist.textColor = [UIColor whiteColor];
		lblDist.backgroundColor = [UIColor clearColor];
		[footerView addSubview:lblDist];
            
        [scrollAddress release];                                                                
        [footerView release];
        
        // Line
        CGRect lineFrame = CGRectMake(0, CELL_HEIGHT - 3, 320, 2);
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        line.tag = 3006;
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
        [line release];
    }
    
    UILabel *labelPlaceName  = (UILabel*)[cell viewWithTag:3002];
    labelPlaceName.frame = CGRectMake(labelPlaceName.frame.origin.x, labelPlaceName.frame.origin.y, nameStringSize.width, nameStringSize.height);
    labelPlaceName.text = place.name;
    
    
    UIScrollView *scrollViewAddress = (UIScrollView*)[cell viewWithTag:3003];
    scrollViewAddress.contentSize = addressStringSize;
    
    NSLog(@"place address %@", [(Place*)[placeList objectAtIndex:indexPath.row] address]);
    
    UILabel *labelAddress = (UILabel*)[cell viewWithTag:3004];
    labelAddress.frame = CGRectMake(labelAddress.frame.origin.x, labelAddress.frame.origin.y, addressStringSize.width, addressStringSize.height);
    labelAddress.text = place.address; 
    
    UILabel *labelDistance = (UILabel*)[cell viewWithTag:3005];
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = place.latitude;
    theCoordinate.longitude = place.longitude;
    float distance = [self getDistanceFromMe:theCoordinate];
    if (distance > 999)
        labelDistance.text = [NSString stringWithFormat:@"%.1fkm", distance/1000.0];
    else
        labelDistance.text = [NSString stringWithFormat:@"%dm", (int)distance];
    
    /*
    UIButton *buttonAddress;
    
    for (UIView *subView in [[cell.contentView viewWithTag:3333] subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            buttonAddress = (UIButton*)subView;
            break;
        }
    }
    
    buttonAddress.tag=indexPath.row;
    */
    UILabel *labelTime = (UILabel*)[cell.contentView viewWithTag:3004];
    UILabel *labelSenderName = (UILabel*)[cell.contentView viewWithTag:3014];
    UILabel *labelMsg = (UILabel*)[[cell.contentView viewWithTag:3333] viewWithTag:3005];
    
    UIImageView *imageViewSender = (UIImageView*) [cell viewWithTag:3006];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  
{   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [placeList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
}

- (void)actionEditPlace:(id)sender
{
    NSLog(@"actionEditPlace tag = %d", [sender tag]);
}

-(void)showInMapview:(id)sender 
{
     NSLog(@"showInMapview tag = %d", [sender tag]);
}

// GCD async notifications
- (void)gotPlaces:(NSNotification *)notif 
{
    placeList = [notif object];

    NSLog(@"placeList = %@", placeList);
    [tableViewPlaceList reloadData];
}


- (void)dealloc 
{
    [tableViewPlaceList release];
    [super dealloc];  
}

- (IBAction)actionBackMe:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
