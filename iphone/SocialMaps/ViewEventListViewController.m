//
//  ViewEventListViewController.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "ViewEventListViewController.h"
#import "EventListTableCell.h"
#import "EventListRsvpTableCell.h"
#import "Event.h"
#import "EventImageDownloader.h"
#import "EventList.h"
#import "Globals.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"


@interface ViewEventListViewController ()

- (void)startIconDownload:(Event *)event forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ViewEventListViewController
@synthesize eventListTableView,eventSearchBar,downloadedImageDict,mapView,mapContainer;
 
__strong NSMutableArray *filteredList, *eventListArray;
__strong NSMutableDictionary *imageDownloadsInProgress;
__strong NSMutableDictionary *eventListIndex;
NSString *searchText=@"";

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
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    [imageDownloadsInProgress retain];
    eventListIndex=[[NSMutableDictionary alloc] init];
    
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    
    downloadedImageDict=[[NSMutableDictionary alloc] init];
    
    [super viewDidLoad];
    Event *aEvent=[[Event alloc] init];
    EventList *eventList=[[EventList alloc] init];
    NSLog(@"eventList.eventListArr: %@  eventListGlobalArray: %@",eventList.eventListArr,eventListGlobalArray);
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.mapContainer removeFromSuperview];
}

-(NSMutableArray *)loadDummyData
{
    NSMutableArray *eventList=[[NSMutableArray alloc] init];
    Event *aEvent=[[Event alloc] init];
// event1    
    aEvent.eventID=@"50360335f69c29bc05000001";
    aEvent.eventName=@"Eid Fair";

    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";

    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";

    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005482.jpg";
    [eventList addObject:aEvent];
    
// event2    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000002";
    aEvent.eventName=@"Birthday";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"29.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Birthday Party";
    aEvent.eventAddress=@"Home";
    aEvent.eventDistance=@"125m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005457.jpg";   
    [eventList addObject:aEvent];
    
// event3    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000003";
    aEvent.eventName=@"Pohela Baishakh";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"30.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Pohela Get together";
    aEvent.eventAddress=@"Ramna Botomul";
    aEvent.eventDistance=@"150m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg";
    [eventList addObject:aEvent];

    // event4    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000004";
    aEvent.eventName=@"Lunch";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005470.jpg";
    [eventList addObject:aEvent];

    // event5    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000005";
    aEvent.eventName=@"Dinner";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005463.jpg";
    [eventList addObject:aEvent];

    // event6    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000006";
    aEvent.eventName=@"breakfast";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005465.jpg";
    [eventList addObject:aEvent];

    // event7    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000007";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005466.jpg";
    [eventList addObject:aEvent];

    // event8    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000008";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005469.jpg";
    [eventList addObject:aEvent];

    
    // event9    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc05000009";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005472.jpg";
    [eventList addObject:aEvent];

    
    // event10    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc050000010";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg";
    [eventList addObject:aEvent];
    
    // event11    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc050000010";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg";
    [eventList addObject:aEvent];

    
    // event12    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc050000010";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg";
    [eventList addObject:aEvent];

    
    // event13    
    aEvent=[[Event alloc] init];
    aEvent.eventID=@"50360335f69c29bc050000010";
    aEvent.eventName=@"Eid Fair";
    
    aEvent.eventDate.timezone=@"Europe/London";
    aEvent.eventDate.timezoneType=@"3";
    aEvent.eventDate.date=@"26.08.2012";
    
    aEvent.eventCreateDate.timezone=@"Europe/London";
    aEvent.eventCreateDate.timezoneType=@"3";
    aEvent.eventCreateDate.date=@"28.08.2012";
    
    aEvent.eventShortSummary=@"Eid Get together";
    aEvent.eventAddress=@"Gulshan circle 2";
    aEvent.eventDistance=@"100m";
    aEvent.eventLocation.latitude=@"10";
    aEvent.eventLocation.longitude=@"20";
    aEvent.willAttend=@"yes";
    aEvent.eventImageUrl=@"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg";
    [eventList addObject:aEvent];


    for (int i=0; i<[eventListGlobalArray count]; i++)
    {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        Event *aEvent=[[Event alloc] init];
        Event *aEvent2=[[Event alloc] init];
        aEvent=[eventListGlobalArray objectAtIndex:i];
        aEvent2=[eventList objectAtIndex:i];
        NSLog(@"aEvent.eventImageUrl: %@",aEvent.eventImageUrl);
        if (!(aEvent.eventImageUrl)||(aEvent.eventImageUrl==(NSString *)[NSNull null]))
        {
            aEvent.eventImageUrl=aEvent2.eventImageUrl;
            NSLog(@"aEvent.eventImageUrl %@ aEvent2.eventImageUrl %@",aEvent.eventImageUrl,aEvent2.eventImageUrl);
        }
        [eventListGlobalArray replaceObjectAtIndex:i withObject:aEvent];
        [pool drain];
    }
    return eventListGlobalArray;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)dateAction:(id)sender
{
    NSLog(@"date");
}

-(IBAction)distanceAction:(id)sender
{
    NSLog(@"distance");
}

-(IBAction)friendsEventAction:(id)sender
{
    NSLog(@"friends event");
}

-(IBAction)myEventAction:(id)sender
{
    NSLog(@"my event");
}

-(IBAction)publicEventAction:(id)sender
{
    NSLog(@"public event");
}

-(IBAction)newEventAction:(id)sender
{
    NSLog(@"new event");
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
    
    EventListTableCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifier];
    EventListRsvpTableCell *cell1= [tableView
                                    dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell == nil)
    {
        if (indexPath.row==1)
        {
            cell1 = [[EventListRsvpTableCell alloc]
                     initWithStyle:UITableViewCellStyleDefault 
                     reuseIdentifier:CellIdentifier1];
        }
        else
        {
            cell = [[EventListTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault 
                    reuseIdentifier:CellIdentifier];
        }
    }
    
    // Configure the cell...
    cell.eventAddress.text = [NSString stringWithFormat:@"event address"];
    cell.eventName.text = [NSString stringWithFormat:@"event name"];
    cell.eventDate.text = [NSString stringWithFormat:@"event date"];
//    cell.eventDetail.text = [NSString stringWithFormat:@"1"];
    cell.eventDistance.text = [NSString stringWithFormat:@"event distance"];
    cell.viewEventOnMap.tag=indexPath.row;
    [cell.viewEventOnMap addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell1.yesButton.tag=indexPath.row;
    cell1.noButton.tag=indexPath.row;
    cell1.maybesButton.tag=indexPath.row;
    cell1.viewEventOnMap.tag=indexPath.row;
    
    [cell1.yesButton addTarget:self action:@selector(yesButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell1.noButton addTarget:self action:@selector(noButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell1.maybesButton addTarget:self action:@selector(maybeButton:) forControlEvents:UIControlEventTouchUpInside];    
    [cell1.viewEventOnMap addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];     
    UIImage *eventPhoto = [UIImage imageNamed:@"1.png"];
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        Event *event = [filteredList objectAtIndex:indexPath.row];
        
		NSString *cellValue;		
        cellValue=event.eventName;
        cell.eventName.text = cellValue;
        cell.eventDetail.text=event.eventShortSummary;
        cell.eventDate.text=event.eventDate.date;
        cell.eventAddress.text=event.eventAddress;
        cell.eventDistance.text=[NSString stringWithFormat:@"%.2lfm",[event.eventDistance doubleValue]];
        
        cell1.eventName.text = cellValue;
        cell1.eventDetail.text=event.eventShortSummary;
        cell1.eventDate.text=event.eventDate.date;
        cell1.eventAddress.text=event.eventAddress;
        cell1.eventDistance.text=[NSString stringWithFormat:@"%.2lfm",[event.eventDistance doubleValue]];

        
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
            cell.eventImage.image=[UIImage imageNamed:@"girl.png"];                
            cell1.eventImage.image=[UIImage imageNamed:@"girl.png"];                
        }
        
        if ([downloadedImageDict objectForKey:event.eventID])
        {
            cell.eventImage.image=[downloadedImageDict objectForKey:event.eventID];                
            cell1.eventImage.image=[downloadedImageDict objectForKey:event.eventID];      
        }
        else
        {
            cell.eventImage.image=[UIImage imageNamed:@"girl.png"];                
            cell1.eventImage.image=[UIImage imageNamed:@"girl.png"];      
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
    
    NSLog(@"downloadedImageDict c: %@ %d",downloadedImageDict,[downloadedImageDict count]);
//    cell.eventImage.image = eventPhoto;
    if (indexPath.row%2==1)
    {
        return cell1;        
    }
    else
    {
        return cell;
    }
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (rsvpFlag)
//        {
//            return 122;
//    }
//    else if(indexPath.row==1)
//    {
//        return 172;
//    }
//    return 122;
//}

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
        //UserFriends *friend = [filteredList objectAtIndex:indexPath.row];
        //friend.userProfileImage = iconDownloader.userFriends.userProfileImage;
        NSNumber *indx = [eventListIndex objectForKey:eventID];
        Event *event = [eventListArray objectAtIndex:[indx intValue]];
        event.eventImage = iconDownloader.event.eventImage;
        
        EventListTableCell *cell = [self.eventListTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        EventListRsvpTableCell *cell1 = [self.eventListTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
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
        filteredList = [[NSMutableArray alloc] initWithArray: eventListArray];
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
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
    [self.eventListTableView reloadData];
    [eventSearchBar resignFirstResponder];
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
        filteredList = [[NSMutableArray alloc] initWithArray: eventListArray];
    }
    else
        for (Event *sTemp in eventListArray)
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
}

-(IBAction)noButton:(id)sender
{
    NSLog(@"noButton tag: %d",[sender tag]);
    EventListRsvpTableCell *clickedCell = (EventListRsvpTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.eventListTableView indexPathForCell:clickedCell];
    [clickedCell.yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [clickedCell.noButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [clickedCell.maybesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
    NSLog(@"clickedButtonPath %@",clickedButtonPath);    
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
	
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
	annotation.title = aEvent.eventAddress;
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	annotation.subtitle=[NSString stringWithFormat:@"%.2lfm",[aEvent.eventDistance doubleValue]];
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

@end
