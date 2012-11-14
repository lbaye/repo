//
//  ViewEventListViewController.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewEventListViewController.h"
#import "EventListTableCell.h"
#import "EventListRsvpTableCell.h"
#import "Event.h"
#import "EventImageDownloader.h"
#import "EventList.h"
#import "Globals.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "ViewEventDetailViewController.h"
#import "UtilityClass.h"
#import "CreateEventViewController.h"
#import "NotificationController.h"

@interface ViewEventListViewController ()

- (void)startIconDownload:(Event *)event forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ViewEventListViewController
@synthesize eventListTableView,eventSearchBar,downloadedImageDict,mapView,mapContainer,newEventButton;
 
@synthesize dateButton;
@synthesize distanceButton;
@synthesize friendsEventButton;
@synthesize myEventButton;
@synthesize publicEventButton;
@synthesize totalNotifCount;

__strong NSMutableArray *filteredList, *eventListArray;
__strong NSMutableDictionary *imageDownloadsInProgress;
__strong NSMutableDictionary *eventListIndex;
NSString *searchText=@"";
AppDelegate         *smAppDelegate;

//rsvpFlag=
bool searchFlags=true;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    filteredList=[[NSMutableArray alloc] init]; 
    eventListArray=[[NSMutableArray alloc] init];
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    [imageDownloadsInProgress retain];
    eventListIndex=[[NSMutableDictionary alloc] init];
    
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    
    downloadedImageDict=[[NSMutableDictionary alloc] init];
    
    [super viewDidLoad];
    EventList *eventList=[[EventList alloc] init];
    NSLog(@"eventList.eventListArr: %@  eventListGlobalArray: %@",eventList.eventListArr,eventListGlobalArray);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRsvpDone:) name:NOTIF_SET_RSVP_EVENT_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllEventsDone:) name:NOTIF_GET_ALL_EVENTS_DONE object:nil];

	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    filteredList=[[self loadDummyData] mutableCopy]; 
//    eventListArray=[[self loadDummyData] mutableCopy];
    [self displayNotificationCount];
    [self.mapContainer removeFromSuperview];
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    NSLog(@"activity start.  %@",smAppDelegate);
    [self.eventSearchBar setText:@""];
}

-(void)viewDidAppear:(BOOL)animated
{
    [dateButton setBackgroundColor:[UIColor lightGrayColor]];
    [distanceButton setBackgroundColor:[UIColor clearColor]];
    [friendsEventButton setBackgroundColor:[UIColor clearColor]];
    [myEventButton setBackgroundColor:[UIColor clearColor]];
    [publicEventButton setBackgroundColor:[UIColor clearColor]];
    
    RestClient *rc=[[RestClient alloc] init];
    [rc getAllEvents:@"Auth-Token":smAppDelegate.authToken];  
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [filteredList removeAllObjects];
    [eventListArray removeAllObjects];
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    [self.eventListTableView reloadData];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.eventSearchBar resignFirstResponder];
}

-(NSMutableArray *)loadDummyData
{
    for (int i=0; i<[eventListGlobalArray count]; i++)
    {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        Event *aEvent=[[Event alloc] init];
        aEvent=[eventListGlobalArray objectAtIndex:i];
        if (!(aEvent.eventImageUrl)||(aEvent.eventImageUrl==(NSString *)[NSNull null]))
        {
            aEvent.eventImageUrl=[[NSBundle mainBundle] pathForResource:@"blank" ofType:@"png"];
        }
        NSLog(@"aEvent.eventImageUrl: %@",aEvent.eventImageUrl);
        [eventListGlobalArray replaceObjectAtIndex:i withObject:aEvent];
        [pool drain];
    }
    return eventListGlobalArray;
}

- (void)getAllEventsDone:(NSNotification *)notif
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    eventListGlobalArray=[[notif object] mutableCopy];
    NSLog(@"GOT SERVICE DATA EVENT.. :D  %@",[notif object]);
//    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [self hideActivity];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.view setNeedsDisplay];
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    if (showFrndsEvents==true)
    {
        [self friendsEventAction:nil];
    }
    showFrndsEvents=false;
    [self.eventListTableView reloadData];
}

-(void)hideActivity
{
    NSArray* subviews = [NSArray arrayWithArray: self.view.subviews];
    for (UIView* view in subviews) 
    {
        if([view isKindOfClass :[UIActivityIndicatorView class]])
        {
            [view removeFromSuperview];
        }
    }

    [smAppDelegate hideActivityViewer];
    NSLog(@"activity removed %@",smAppDelegate);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)dateAction:(id)sender
{
    NSLog(@"date");
        [self.eventSearchBar resignFirstResponder];
    //Event *even=[[Event alloc] init];
    //even.eventDate.date
    
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    [self.eventListTableView reloadData];
    
    [dateButton setBackgroundColor:[UIColor lightGrayColor]];
    [distanceButton setBackgroundColor:[UIColor clearColor]];
    [friendsEventButton setBackgroundColor:[UIColor clearColor]];
    [myEventButton setBackgroundColor:[UIColor clearColor]];
    [publicEventButton setBackgroundColor:[UIColor clearColor]];
}

-(IBAction)distanceAction:(id)sender
{
    NSLog(@"distance");
        [self.eventSearchBar resignFirstResponder];
    filteredList = [[eventListArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Event*)a eventDistance];
        NSString *second = [(Event*)b eventDistance];
        return [first compare:second];
    }] mutableCopy];
    
    [self.eventListTableView reloadData];
    
    [dateButton setBackgroundColor:[UIColor clearColor]];
    [distanceButton setBackgroundColor:[UIColor lightGrayColor]];
    [friendsEventButton setBackgroundColor:[UIColor clearColor]];
    [myEventButton setBackgroundColor:[UIColor clearColor]];
    [publicEventButton setBackgroundColor:[UIColor clearColor]];

}

-(IBAction)friendsEventAction:(id)sender
{
    NSLog(@"friends event");
        [self.eventSearchBar resignFirstResponder];
    Event *event;
    [filteredList removeAllObjects];
    for (int i=0; i<[eventListArray count]; i++)
    {
        event=[[Event alloc] init];
        event=[eventListArray objectAtIndex:i];
        if ([event.eventType isEqualToString:@"friends_event"])
        {
            [filteredList addObject:event];
        }
    }
    
    [dateButton setBackgroundColor:[UIColor clearColor]];
    [distanceButton setBackgroundColor:[UIColor clearColor]];
    [friendsEventButton setBackgroundColor:[UIColor lightGrayColor]];
    [myEventButton setBackgroundColor:[UIColor clearColor]];
    [publicEventButton setBackgroundColor:[UIColor clearColor]];

    
    [self.eventListTableView reloadData];
    if ([filteredList count]==0)
    {
        [UtilityClass showAlert:@"Social Maps" :@"No friends event found"];
    }
}

-(IBAction)myEventAction:(id)sender
{
    NSLog(@"my event");
        [self.eventSearchBar resignFirstResponder];
    Event *event;
    [filteredList removeAllObjects];
    for (int i=0; i<[eventListArray count]; i++)
    {
        event=[[Event alloc] init];
        event=[eventListArray objectAtIndex:i];
        if ([event.eventType isEqualToString:@"my_event"])
        {
            [filteredList addObject:event];
        }
    }
    
    [dateButton setBackgroundColor:[UIColor clearColor]];
    [distanceButton setBackgroundColor:[UIColor clearColor]];
    [friendsEventButton setBackgroundColor:[UIColor clearColor]];
    [myEventButton setBackgroundColor:[UIColor lightGrayColor]];
    [publicEventButton setBackgroundColor:[UIColor clearColor]];

    [self.eventListTableView reloadData];
    if ([filteredList count]==0)
    {
        [UtilityClass showAlert:@"Social Maps" :@"No my event found"];
    }

}

-(IBAction)publicEventAction:(id)sender
{
    NSLog(@"public event");
        [self.eventSearchBar resignFirstResponder];
    Event *event;
    [filteredList removeAllObjects];
    for (int i=0; i<[eventListArray count]; i++)
    {
        event=[[Event alloc] init];
        event=[eventListArray objectAtIndex:i];
        if ([event.permission isEqualToString:@"public"])
        {
            [filteredList addObject:event];
        }
    }
    
    [dateButton setBackgroundColor:[UIColor clearColor]];
    [distanceButton setBackgroundColor:[UIColor clearColor]];
    [friendsEventButton setBackgroundColor:[UIColor clearColor]];
    [myEventButton setBackgroundColor:[UIColor clearColor]];
    [publicEventButton setBackgroundColor:[UIColor lightGrayColor]];

    [self.eventListTableView reloadData];
    if ([filteredList count]==0)
    {
        [UtilityClass showAlert:@"Social Maps" :@"No public event found"];
    }
}

-(IBAction)newEventAction:(id)sender
{
//    [self.eventListTableView reloadData];
    [self.eventSearchBar resignFirstResponder];
    NSLog(@"new event");
    isFromVenue=FALSE;
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CreateEventViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"createEvent"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

//table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [filteredList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventListCell";
    static NSString *CellIdentifier1 = @"eventListCellRsvp";
    int nodeCount = [filteredList count];
    
    Event *event=[[Event alloc] init];
    event = [filteredList objectAtIndex:indexPath.row];
    NSLog(@"[filteredList count] %d",[filteredList count]);
    
    EventListTableCell *cell = (EventListTableCell *)[tableView
                              dequeueReusableCellWithIdentifier:CellIdentifier];
    EventListRsvpTableCell *cell1= (EventListRsvpTableCell *)[tableView
                                    dequeueReusableCellWithIdentifier:CellIdentifier1];
    NSLog(@"cell %@ cell1 %@",cell, cell );
    if (cell == nil)
    {
        if ((event.isInvited==false)&&([NSNumber numberWithBool:event.isInvited]!=NULL))
        {
            cell = [[EventListTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault 
                    reuseIdentifier:CellIdentifier];
                        
            NSLog(@"cell is null");

        }
    }
    if (cell1 == nil)
    {
        cell1 = [[EventListRsvpTableCell alloc]
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:CellIdentifier1];
            NSLog(@"in create cell1");
    }
    
    CustomRadioButton *radio =(CustomRadioButton *)[cell1.contentView viewWithTag:20001];
    if (radio==NULL)
    {
        NSLog(@"radio null");
        radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(139, 125, 170, 42) numButtons:3 labels:[NSArray arrayWithObjects:@"Yes",@"No",@"May be",nil]  default:0 sender:self tag:20001];
        radio.delegate = self;
        [cell1.contentView addSubview:radio];
    }
    if (event.isInvited==false)
    {
        [radio removeFromSuperview];
    }
    if ((event.isInvited==true)&&([NSNumber numberWithBool:event.isInvited]!=NULL))
    {
        if ([event.myResponse isEqualToString:@"yes"]) 
        {
            [radio gotoButton:0];
        }
        else if ([event.myResponse isEqualToString:@"no"])
        {
            [radio gotoButton:1];        
        }
        else if ([event.myResponse isEqualToString:@"maybe"]) 
        {
            [radio gotoButton:2];        
        }
    }
    if([smAppDelegate.userId isEqualToString:event.owner])
    {
        [radio setUserInteractionEnabled:NO];
    }
    /*
    cell.eventName.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    cell.eventDetail.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    cell.eventDate.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    cell1.eventName.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    cell1.eventDetail.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    cell1.eventDate.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    [cell.eventName.layer setCornerRadius:3.0f];
    [cell.eventDate.layer setCornerRadius:3.0f];
    [cell.eventAddress.layer setCornerRadius:3.0f];
    [cell.eventDistance.layer setCornerRadius:3.0f];
    [cell.eventDetail.layer setCornerRadius:3.0f];
    [cell1.eventName.layer setCornerRadius:3.0f];
    [cell1.eventDate.layer setCornerRadius:3.0f];
    [cell1.eventAddress.layer setCornerRadius:3.0f];
    [cell1.eventDistance.layer setCornerRadius:3.0f];
    [cell1.eventDetail.layer setCornerRadius:3.0f];*/
    // Configure the cell...
    cell.eventDate.text = [NSString stringWithFormat:@"event date"];
//    cell.eventDetail.text = [NSString stringWithFormat:@"1"];
    cell.eventDistance.text = [NSString stringWithFormat:@"event distance"];
    cell.viewEventOnMap.tag=indexPath.row;
    [cell.viewEventOnMap addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    cell1.tag=indexPath.row;
    cell1.yesButton.tag=indexPath.row;
    cell1.noButton.tag=indexPath.row;
    cell1.maybesButton.tag=indexPath.row;
    cell1.viewEventOnMap.tag=indexPath.row;
//    NSLog(@"event.myResponse: %@",event.myResponse);
    NSLog(@"event: %@",event);
    if ((event.isInvited==true)&&([NSNumber numberWithBool:event.isInvited]!=NULL))
    {
        if ([event.myResponse isEqualToString:@"yes"])
        {
            [cell1.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
            [cell1.noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
            [cell1.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        }
        else if([event.myResponse isEqualToString:@"no"]) 
        {
            [cell1.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
            [cell1.noButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
            [cell1.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];            
        }
        else
        {
            [cell1.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
            [cell1.noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
            [cell1.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];            
        }
    }
    
    if([smAppDelegate.userId isEqualToString:event.owner])
    {
        
        [cell1.yesButton setUserInteractionEnabled:NO];
        [cell1.noButton setUserInteractionEnabled:NO];
        [cell1.maybesButton setUserInteractionEnabled:NO];
        
        [cell1.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [cell1.noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [cell1.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell1.yesButton setUserInteractionEnabled:YES];
        [cell1.noButton setUserInteractionEnabled:YES];
        [cell1.maybesButton setUserInteractionEnabled:YES];
    }

    
    [cell1.yesButton addTarget:self action:@selector(yesButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell1.noButton addTarget:self action:@selector(noButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell1.maybesButton addTarget:self action:@selector(maybeButton:) forControlEvents:UIControlEventTouchUpInside];    
    [cell1.viewEventOnMap addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];     
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        
        
		NSString *cellValue;		
        cellValue=event.eventName;
        CGSize lblStringSize = [cellValue sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
        
        cell.eventName.frame=CGRectMake(cell.eventName.frame.origin.x, cell.eventName.frame.origin.y, lblStringSize.width, lblStringSize.height);
        cell1.eventName.frame=CGRectMake(cell1.eventName.frame.origin.x, cell.eventName.frame.origin.y, lblStringSize.width, lblStringSize.height);
        NSLog(@"lblStringSize %@ %@",NSStringFromCGSize(lblStringSize),NSStringFromCGRect(cell.eventName.frame));
        cell.eventNameScrollView.contentSize=cell.eventName.frame.size;
        cell1.eventNameScrollView.contentSize=cell1.eventName.frame.size;
        
        cell.eventName.text = cellValue;
        cell.eventDetail.text=event.eventShortSummary;
        cell.eventDate.text=[UtilityClass getCurrentTimeOrDate:event.eventDate.date];
//        cell.eventDate.text=event.eventDate.date;
        cell.eventAddress.text=event.eventAddress;
        CGSize lblStringSize1 = [event.eventAddress sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
        
        cell.eventAddress.frame=CGRectMake(cell.eventAddress.frame.origin.x, cell.eventAddress.frame.origin.y, lblStringSize1.width, lblStringSize1.height);
        cell1.eventAddress.frame=CGRectMake(cell1.eventAddress.frame.origin.x, cell.eventAddress.frame.origin.y, lblStringSize1.width, lblStringSize1.height);       
        cell.eventAddressScrollView.contentSize=cell.eventAddress.frame.size;
        cell1.eventAddressScrollView.contentSize=cell1.eventAddress.frame.size;
        cell.eventDistance.text = [UtilityClass getDistanceWithFormattingFromLocation:event.eventLocation];
        cell1.eventDistance.text = [UtilityClass getDistanceWithFormattingFromLocation:event.eventLocation];

        
        cell1.eventName.text = cellValue;
        cell1.eventName.frame=CGRectMake(cell.eventName.frame.origin.x, cell.eventName.frame.origin.y, lblStringSize.width, lblStringSize.height);
        cell1.eventNameScrollView.contentSize=cell.eventName.frame.size;
        cell1.eventDetail.text=event.eventShortSummary;
//        cell1.eventDate.text=event.eventDate.date;
        cell1.eventDate.text=[UtilityClass getCurrentTimeOrDate:event.eventDate.date];
        cell1.eventAddress.text=event.eventAddress;

        
        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0 %@",event.eventImageUrl);
        if (!event.eventImage)
        {
            NSLog(@"!userFriends.userProfileImage");
            if (self.eventListTableView.dragging == NO && self.eventListTableView.decelerating == NO)
            {
                [self startIconDownload:event forIndexPath:indexPath];
                NSLog(@"Downloading for %@ index=%d", cellValue, indexPath.row);
            }            
            else if(searchFlags==true)
            {
                NSLog(@"search flag true start download");
                [self startIconDownload:event forIndexPath:indexPath];
            }
           
            NSLog(@"userFriends %@   %@",event.eventImage,event.eventImageUrl);
            // if a download is deferred or in progress, return a placeholder image
            cell.eventImage.image=[UIImage imageNamed:@"blank.png"];                
            cell1.eventImage.image=[UIImage imageNamed:@"blank.png"];                
        }
        
        if ([downloadedImageDict objectForKey:event.eventID])
        {
            cell.eventImage.image=[downloadedImageDict objectForKey:event.eventID];                
            cell1.eventImage.image=[downloadedImageDict objectForKey:event.eventID];      
        }
        else
        {
            cell.eventImage.image=[UIImage imageNamed:@"blank.png"];                
            cell1.eventImage.image=[UIImage imageNamed:@"blank.png"];      
        }
        
//        else if ([[imageDownloadsInProgress objectForKey:event.eventID]isEqual:event.eventID]&&([imageDownloadsInProgress objectForKey:event.eventImage]!=NULL) ) 
//        {
//             EventImageDownloader *iconDownloader=[imageDownloadsInProgress objectForKey:event.eventID];
//            cell.eventImage.image = iconDownloader.event.eventImage;
//            cell1.eventImage.image = iconDownloader.event.eventImage;
//        }
//        else
//        {
//            cell.eventImage.image = event.eventImage;
//            cell1.eventImage.image=event.eventImage;                
//        }
    }
    
    cell.eventImage.contentMode = UIViewContentModeScaleAspectFit;
    cell1.eventImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell1.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"downloadedImageDict c: %@ %d",downloadedImageDict,[downloadedImageDict count]);
//    cell.eventImage.image = eventPhoto;
    if (event.isInvited==false)
    {
        return cell;        
    }
    else
    {
        return cell1;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:indexPath.row];
    if (aEvent.isInvited==false)
    {
            return 122;
    }
    else
    {
        return 172;
    }
    return 122;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    
//    [smAppDelegate showActivityViewer:self.view];
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:indexPath.row];
    globalEvent=[[Event alloc] init];
    globalEvent=aEvent;
    NSLog(@"globalEvent.eventImage: %@",globalEvent.eventImage);
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
    [self presentModalViewController:controller animated:YES];

}

//Lazy loading method starts

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(Event *)event forIndexPath:(NSIndexPath *)indexPath
{
    EventImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:event.eventID];
    if (iconDownloader == nil)
    {
        iconDownloader = [[EventImageDownloader alloc] init];
        iconDownloader.event = event;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:event.eventID];
        NSLog(@"imageDownloadsInProgress %@",imageDownloadsInProgress);
        [iconDownloader startDownload];
        //[downloadedImageDict setValue:iconDownloader.event.eventImage forKey:event.eventID];
        NSLog(@"start downloads ... %@ %d",event.eventID, indexPath.row);
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([filteredList count] > 0)
    {
        NSArray *visiblePaths = [self.eventListTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Event *event = [filteredList objectAtIndex:indexPath.row];
            
            if (!event.eventImage) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:event forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)eventID
{
    EventImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:eventID];
    if (iconDownloader != nil)
    {
        Event *event = [eventListArray objectAtIndex:iconDownloader.indexPathInTableView.row];
        event.eventImage = iconDownloader.event.eventImage;
        
        EventListTableCell *cell = (EventListTableCell *)[self.eventListTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        EventListRsvpTableCell *cell1 = (EventListRsvpTableCell *)[self.eventListTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        [downloadedImageDict setValue:iconDownloader.event.eventImage forKey:eventID];
        cell.eventImage.image = iconDownloader.event.eventImage;
        cell1.eventImage.image = iconDownloader.event.eventImage;
        //[userProfileCopyImageArray replaceObjectAtIndex:indexPath.row withObject:iconDownloader.userFriends.userProfileImage];
        [self.eventListTableView reloadData];
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

//Lazy loading method ends.


//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    //[self loadFriendListsData]; TODO: commented this
    searchText=eventSearchBar.text;
    
    [newEventButton setUserInteractionEnabled:NO];
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlags=true;
        [self.eventListTableView reloadData];
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchText=@"";
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: eventListGlobalArray];
        NSLog(@"eventListGlobalArray: %@",eventListGlobalArray);
        [self.eventListTableView reloadData];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    searchText=eventSearchBar.text;
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    
    NSLog(@"2");  
    [newEventButton setUserInteractionEnabled:NO];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
    [self.eventListTableView reloadData];
    [eventSearchBar resignFirstResponder];
        [newEventButton setUserInteractionEnabled:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    eventSearchBar.text=@"";
    searchText=@"";
    
    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: eventListArray];
    [self.eventListTableView reloadData];
    [eventSearchBar resignFirstResponder];
    NSLog(@"3");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    
    NSLog(@"Search button clicked");
    searchText=eventSearchBar.text;
    searchFlags=false;
    [self searchResult];
    [eventSearchBar resignFirstResponder];  
        [newEventButton setUserInteractionEnabled:YES];
}

-(void)searchResult
{
    searchText = eventSearchBar.text;
    NSLog(@"in search method..");
    [filteredList removeAllObjects];
    
    if ([searchText isEqualToString:@""])
    {
        NSLog(@"null string");
        eventSearchBar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: eventListGlobalArray];
    }
    else
        for (Event *sTemp in eventListGlobalArray)
        {
            NSRange titleResultsRange = [sTemp.eventName rangeOfString:searchText options:NSCaseInsensitiveSearch];		
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.eventName);            
            }
            else
            {
            }
        }
    searchFlags=false;
    
    NSLog(@"filteredList %@ %d  %d  imageDownloadsInProgress: %@",filteredList,[filteredList count],[eventListArray count], imageDownloadsInProgress);
    [self.eventListTableView reloadData];
}
//searchbar delegate method end

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)yesButton:(id)sender
{
    NSLog(@"yesButton tag: %d",[sender tag]);
    EventListRsvpTableCell *clickedCell = (EventListRsvpTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.eventListTableView indexPathForCell:clickedCell];
    [clickedCell.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [clickedCell.noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [clickedCell.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
    NSLog(@"clickedButtonPath %@",clickedButtonPath);
    
    
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:clickedButtonPath.row];
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:aEvent.eventID:@"yes":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];

//    -(void)setEventRsvp:(NSString *) eventID:(NSString *) rsvp:(NSString *)authToken:(NSString *)authTokenValue
}

-(IBAction)noButton:(id)sender
{
    NSLog(@"noButton tag: %d",[sender tag]);
    EventListRsvpTableCell *clickedCell = (EventListRsvpTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.eventListTableView indexPathForCell:clickedCell];
    [clickedCell.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [clickedCell.noButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [clickedCell.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
    
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:clickedButtonPath.row];
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:aEvent.eventID:@"no":@"Auth-Token":smAppDelegate.authToken];
    NSLog(@"clickedButtonPath %@",clickedButtonPath); 
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];

}

-(IBAction)maybeButton:(id)sender
{
    NSLog(@"maybeButton tag: %d",[sender tag]);
    EventListRsvpTableCell *clickedCell = (EventListRsvpTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.eventListTableView indexPathForCell:clickedCell];
    [clickedCell.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [clickedCell.noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [clickedCell.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];    
    NSLog(@"clickedButtonPath %@",clickedButtonPath);
    
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:clickedButtonPath.row];
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:aEvent.eventID:@"maybe":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];

}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[[[sender superview] superview] tag]);
    
    
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:[[[sender superview] superview] tag]];
    RestClient *rc=[[RestClient alloc] init];
    
    [smAppDelegate hideActivityViewer];
//    [smAppDelegate.window setUserInteractionEnabled:NO];
    
    if ([sender tag] == 20001) 
    {
        switch (indx) 
        {
            case 2:
                NSLog(@"may be");
                aEvent.myResponse=@"maybe";
                [filteredList replaceObjectAtIndex:[[[sender superview] superview] tag] withObject:aEvent];
                NSLog(@"eventID %@",aEvent.eventID);
                [rc setEventRsvp:aEvent.eventID:@"maybe":@"Auth-Token":smAppDelegate.authToken];
                break;
            case 1:
                NSLog(@"no");
                aEvent.myResponse=@"no";
                [filteredList replaceObjectAtIndex:[[[sender superview] superview] tag] withObject:aEvent];
                NSLog(@"eventID %@",aEvent.eventID);
                [rc setEventRsvp:aEvent.eventID:@"no":@"Auth-Token":smAppDelegate.authToken];
                break;
            case 0:
                NSLog(@"yes");
                aEvent.myResponse=@"yes";
                [filteredList replaceObjectAtIndex:[[[sender superview] superview] tag] withObject:aEvent];
                NSLog(@"eventID %@",aEvent.eventID);
                [rc setEventRsvp:aEvent.eventID:@"yes":@"Auth-Token":smAppDelegate.authToken];
                break;
            default:
                break;
        }
    }
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self.eventSearchBar resignFirstResponder];
}

-(IBAction)viewLocationButton:(id)sender

{
    NSLog(@"maybeButton tag: %d",[sender tag]);
    EventListRsvpTableCell *clickedCell = (EventListRsvpTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.eventListTableView indexPathForCell:clickedCell];
    [self.view addSubview:self.mapContainer];
    NSLog(@"clickedButtonPath %@",clickedButtonPath); 
    
    Event *aEvent=[[Event alloc] init];
    aEvent=[filteredList objectAtIndex:[sender tag]];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [aEvent.eventLocation.latitude doubleValue];
    theCoordinate.longitude = [aEvent.eventLocation.longitude doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES]; 

    
    //[self.mapView setRegion:newRegion animated:YES];
    NSLog(@"lat %lf ",[aEvent.eventLocation.latitude doubleValue]);
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];

    if (!aEvent.eventAddress)
    {
        aEvent.eventAddress=@"Not found";
    }
	annotation.title =[NSString stringWithFormat:@"%@",aEvent.eventAddress];
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	annotation.subtitle=[UtilityClass getDistanceWithFormattingFromLocation:aEvent.eventLocation];
	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapView addAnnotation:annotation];
}

-(IBAction)closeMapView:(id)sender
{
    NSLog(@"close map");
    [self.mapContainer removeFromSuperview];
}

//handling map view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) 
    {
		draggablePinView.annotation = annotation;
	}
    else 
    {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
        
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) 
        {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else
        {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}		
	
	return draggablePinView;
}


- (void)setRsvpDone:(NSNotification *)notif
{
    NSLog(@"rsvp updated.");
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];    
}


@end
