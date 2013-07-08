//
//  ViewEventDetailViewController.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "ViewEventDetailViewController.h"
#import "Globals.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "UtilityClass.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "UserFriends.h"
#import <QuartzCore/QuartzCore.h>
#import "NotificationController.h"
#import "SelectCircleTableCell.h"
#import "UIImageView+Cached.h"
#import "CreateEventViewController.h"

@implementation ViewEventDetailViewController
@synthesize eventName,eventDate,eventShortDetail,eventAddress,eventDistance;    
@synthesize yesButton,noButton,maybeButton,descriptionView,guestScrollView,rsvpView,detailView;
@synthesize mapContainer,mapView,eventImgView;
@synthesize editEventButton;
@synthesize deleteEventButton;    
@synthesize inviteEventButton,totalNotifCount;               
@synthesize addressScollview,imagesName,results,frndsScrollView,circleTableView,friendSearchbar,segmentControl,customView;

NSMutableArray *imageArr, *nameArrEventDetail, *idArr;
bool menuOpen=NO;
AppDelegate *smAppDelegate;
int notfCounter=0;
int inviteNotfCounter=0;
int detNotfCounter=0;
BOOL isBackgroundTaskRunning=FALSE;
CustomRadioButton *radio;


NSMutableArray *selectedFriends;
NSMutableArray *selectedCircleCheckArr;
NSMutableArray *circleList, *ImgesName, *friendListArr, *friendsIDArr, *friendsNameArr;
NSString *searchTexts;
NSMutableArray *FriendList;
NSString *searchText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    RestClient *rc=[[RestClient alloc] init];
    NSLog(@"globalEvent %@ %@",globalEvent,globalEvent.eventID);
    [rc getEventDetailById:globalEvent.eventID:@"Auth-Token":smAppDelegate.authToken];
    [rc release];

}

-(void)initView
{
    
    descriptionView.text=globalEvent.eventDescription;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    NSLog(@"smAppDelegate.userId: %@",smAppDelegate.userId);
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    Event *aEvent=globalEvent;
    NSLog(@"aEvent.eventID: %@  smAppDelegate.authToken: %@",aEvent.eventID,smAppDelegate.authToken);
    
    isBackgroundTaskRunning=TRUE;
    
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    eventName.text=globalEvent.eventName;
    eventDate.text=[UtilityClass getCurrentTimeOrDate:globalEvent.eventDate.date];
    eventShortDetail.text=globalEvent.eventShortSummary;
    CGSize lblStringSize = [globalEvent.eventAddress sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0f]];
    eventAddress.frame=CGRectMake(eventAddress.frame.origin.x, eventAddress.frame.origin.y, lblStringSize.width, lblStringSize.height);
    addressScollview.contentSize=eventAddress.frame.size;
    eventAddress.text=globalEvent.eventAddress;
    eventDistance.text = [UtilityClass getDistanceWithFormattingFromLocation:globalEvent.eventLocation];
    descriptionView.text=globalEvent.eventDescription;
    NSLog(@"event prop: %@ %i  %@",globalEvent.owner,globalEvent.isInvited,globalEvent.guestList);
    
    //mapview data
    if ([self.mapView.annotations count]>0)
    {
        [self.mapView removeAnnotations:[self.mapView annotations]];
    }
    
    [mapView removeAnnotations:[self.mapView annotations]];
    aEvent=globalEvent;
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [aEvent.eventLocation.latitude doubleValue];
    theCoordinate.longitude = [aEvent.eventLocation.longitude doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES]; 
    
    NSLog(@"lat %lf ",[aEvent.eventLocation.latitude doubleValue]);
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
    if (!aEvent.eventAddress)
    {
        aEvent.eventAddress=@"Address not found";
    }
	annotation.title =[NSString stringWithFormat:@"%@",aEvent.eventAddress];
    annotation.subtitle = [UtilityClass getDistanceWithFormattingFromLocation:globalEvent.eventLocation];

	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapView addAnnotation:annotation];
    
    //scroll view data
    //set scroll view content size.
    NSLog(@"setting scroll size.");
    [self reloadScrolview]; 
    
    
    //my response & image
    
    if ((globalEvent.eventImageUrl)&&(!globalEvent.eventImage))
    {
        [self performSelector:@selector(loadImageView) withObject:nil afterDelay:0.1];
        NSLog(@"globalEvent.eventImageUrl %@ globalEvent.eventImage %@",globalEvent.eventImageUrl,globalEvent.eventImage);
    }
    else if(globalEvent.eventImage)
    {
        if (!eventImgView.image) eventImgView.image=globalEvent.eventImage;
        NSLog(@"globalEvent.eventImage %@",globalEvent.eventImage);
    }
    
    if([smAppDelegate.userId isEqualToString:aEvent.owner])
    {
        
        [deleteEventButton setHidden:NO];
        [editEventButton setHidden:NO];
        [inviteEventButton setHidden:NO];
        
        [yesButton setUserInteractionEnabled:NO];
        [noButton setUserInteractionEnabled:NO];
        [maybeButton setUserInteractionEnabled:NO];
        [radio gotoButton:0];
        [radio setUserInteractionEnabled:NO];
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    }
    else
    {
        [deleteEventButton setHidden:YES];
        [editEventButton setHidden:YES];
        [inviteEventButton setHidden:YES];
        
        [yesButton setUserInteractionEnabled:YES];
        [noButton setUserInteractionEnabled:YES];
        [maybeButton setUserInteractionEnabled:YES];
        
        NSLog(@"aEvent.myResponse %@",aEvent.myResponse);
        if ([aEvent.myResponse isEqualToString:@"yes"])
        {
            [radio gotoButton:0];
        }
        else if([aEvent.myResponse isEqualToString:@"no"]) 
        {
            [radio gotoButton:1];        }
        else
        {
            [radio gotoButton:2];        }
    }
    if ((globalEvent.guestCanInvite==TRUE) && (globalEvent.isInvited==TRUE))
    {
        [inviteEventButton setHidden:NO];
    }
    else
    {
        [inviteEventButton setHidden:YES];
    }
}

-(void)loadFriendsNCircleData
{
    circleList=[[NSMutableArray alloc] init];
    [circleList removeAllObjects];
    UserCircle *circle;
    for (int i=0; i<[circleListGlobalArray count]; i++)
    {
        circle=[circleListGlobalArray objectAtIndex:i];
        [circleList addObject:circle.circleName];
    }
    UserFriends *frnds;
    ImgesName = [[NSMutableArray alloc] init];    
    searchTexts=[[NSString alloc] initWithString:@""];
    friendsNameArr=[[NSMutableArray alloc] init];
    friendsIDArr=[[NSMutableArray alloc] init];
    FriendList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    selectedCircleCheckArr=[[NSMutableArray alloc] init];
    selectedFriends=[[NSMutableArray alloc] init];
    
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        frnds=[friendListGlobalArray objectAtIndex:i];
        if ((frnds.imageUrl==NULL)||[frnds.imageUrl isEqual:[NSNull null]])
        {
            frnds.imageUrl=[[NSBundle mainBundle] pathForResource:@"blank" ofType:@"png"];
            NSLog(@"img url null %d",i);
        }
        else
        {
            NSLog(@"img url not null %d",i);            
        }
        NSLog(@"frnds.imageUrl %@  frnds.userName %@ frnds.userId %@",frnds.imageUrl,frnds.userName,frnds.userId);
        
       if(![idArr containsObject:frnds.userId])
       {
        [friendListArr addObject:frnds];
       }
    }    
    FriendList=[friendListArr mutableCopy];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetailDone:) name:NOTIF_GET_EVENT_DETAIL_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteEventDone:) name:NOTIF_DELETE_EVENT_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteFriendsEventDone:) name:NOTIF_INVITE_FRIENDS_EVENT_DONE object:nil];
    
    [super viewWillAppear:animated];
    
    [self displayNotificationCount];
    [self.mapContainer removeFromSuperview];
    detNotfCounter=0;
    imagesName = [[NSMutableArray alloc] init];
    nameArrEventDetail = [[NSMutableArray alloc] init];
    idArr=[[NSMutableArray alloc] init];
    smAppDelegate.currentModelViewController = self;
    [customView removeFromSuperview];
    [self loadFriendsNCircleData];
    [self reloadFriendsScrollview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"globalEvent det %@",globalEvent.eventID);
    radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(140, 0, 170, 43) numButtons:3 labels:[NSArray arrayWithObjects:@"Yes",@"No",@"May be",nil]  default:0 sender:self tag:20001];
    radio.delegate = self;
    [rsvpView addSubview:radio];
    
    notfCounter=0;
    detNotfCounter=0;
    
    
    if (globalEvent.isInvited==FALSE)
    {
        rsvpView.hidden=YES;
    }
    else
        rsvpView.hidden=NO;
    
    //reloading scrollview to start asynchronous download.
    NSLog(@"before reload.");
    [self initView];
    [customView.layer setCornerRadius:8.0f];
    [customView.layer setBorderWidth:1.0];
    [customView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [customView.layer setMasksToBounds:YES];
    NSArray *subviews = [self.friendSearchbar subviews];
    NSLog(@"%@",subviews);
    UIButton *cancelButton = [subviews objectAtIndex:2];
    cancelButton.tintColor = [UIColor grayColor];
    [circleTableView setHidden:YES];
    [frndsScrollView setHidden:NO];
    [friendSearchbar setHidden:NO];
    
    [backgroundImageView.layer setCornerRadius:8.0f];
    [backgroundImageView.layer setMasksToBounds:YES];
    
    guestScrollView.delegate = self;
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[sender tag]);
    RestClient *rc=[[RestClient alloc] init];
    [smAppDelegate hideActivityViewer];
    
    if ([sender tag] == 20001) 
    {
        switch (indx) 
        {
            case 2:
                NSLog(@"may be");
                globalEvent.myResponse=@"maybe";
                NSLog(@"eventID %@",globalEvent.eventID);
                [rc setEventRsvp:globalEvent.eventID:@"maybe":@"Auth-Token":smAppDelegate.authToken];
                break;
            case 1:
                NSLog(@"no");
                globalEvent.myResponse=@"no";
                NSLog(@"eventID %@",globalEvent.eventID);
                [rc setEventRsvp:globalEvent.eventID:@"no":@"Auth-Token":smAppDelegate.authToken];
                break;
            case 0:
                NSLog(@"yes");
                globalEvent.myResponse=@"yes";
                NSLog(@"eventID %@",globalEvent.eventID);
                [rc setEventRsvp:globalEvent.eventID:@"yes":@"Auth-Token":smAppDelegate.authToken];
                break;
            default:
                break;
        }
    }
    [rc release];
}

-(void)loadImageView
{
    if ([dicImages_msg objectForKey:globalEvent.eventID])
    {
        if (!eventImgView.image)
            eventImgView.image=[dicImages_msg objectForKey:globalEvent.eventID];
    }
    else
    {
    UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:globalEvent.eventImageUrl]]];
    if (img)
    {
        if (!eventImgView.image) eventImgView.image=img;
        [dicImages_msg setObject:img forKey:globalEvent.eventID];
    }
//    else
//    {
//        eventImgView.image=[UIImage imageNamed:@"blank.png"];
//    }
    NSLog(@"image setted after download. %@",img);
        [img release];
    }
}

- (void)viewDidUnload
{
    backgroundImageView = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

-(void) reloadFriendsScrollview
{
    NSLog(@"upload create scroll init");
    if (isBackgroundTaskRunning==true)
    {
        int x=0; //declared for imageview x-axis point    
        NSArray* subviews = [NSArray arrayWithArray: frndsScrollView.subviews];
        UIImageView *imgView;
        for (UIView* view in subviews) 
        {
            if([view isKindOfClass :[UIView class]])
            {
                [view removeFromSuperview];
            }
            else if([view isKindOfClass :[UIImageView class]])
            {
            }
        }  
        
        frndsScrollView.contentSize=CGSizeMake([FriendList count]*80, 100);        
        NSLog(@"event create isBgTaskRunning %i, %d",isBackgroundTaskRunning,[FriendList count]);
        for(int i=0; i<[FriendList count];i++)               
        {
            if(i< [FriendList count]) 
            { 
                UserFriends *userFrnd=[FriendList objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                
                if(!isDragging_msg && !isDecliring_msg)
                    [imgView loadFromURL:[NSURL URLWithString:userFrnd.imageUrl]];
                
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 80, 80)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 20)];
                [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
                [name setNumberOfLines:0];
                [name setText:userFrnd.userName];
                [name setBackgroundColor:[UIColor clearColor]];
                imgView.userInteractionEnabled = YES;
                imgView.tag = i;
                aView.tag=i;
                imgView.exclusiveTouch = YES;
                imgView.clipsToBounds = NO;
                imgView.opaque = YES;
                imgView.layer.borderColor=[[UIColor clearColor] CGColor];
                imgView.userInteractionEnabled=YES;
                imgView.layer.borderWidth=2.0;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:7.0];
                imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
                for (int c=0; c<[selectedFriends count]; c++)
                {
                    if ([[FriendList objectAtIndex:i] isEqual:[selectedFriends objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[selectedFriends objectAtIndex:c]);
                    }
                    else
                    {
                    }
                }
                [aView addSubview:imgView];
                [aView addSubview:name];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [aView addGestureRecognizer:tapGesture];
                [tapGesture release];           
                [frndsScrollView addSubview:aView];
                [aView release];
                [name release];
                [imgView release];
            }        
            x+=80;
        }
    }
}

-(void)DownLoadFriends:(NSNumber *)path
{
    if (isBackgroundTaskRunning==true)
    {
        int index = [path intValue];
        UserFriends *userFrnd=[FriendList objectAtIndex:index];
        
        NSString *Link = userFrnd.imageUrl;
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
            [self reloadFriendsScrollview];
        }
        [img release];
        // Now, we need to reload scroll view to load downloaded image
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    NSArray* subviews = [NSArray arrayWithArray: frndsScrollView.subviews];
    if ([selectedFriends containsObject:[FriendList objectAtIndex:[sender.view tag]]])
    {
        [selectedFriends removeObject:[FriendList objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [selectedFriends addObject:[FriendList objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[FriendList objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriends : %@ %@",selectedFriends,frndsScrollView);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        
        if ([im1.image isEqual:frnds.userProfileImage])
        {
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
    }
    [self reloadFriendsScrollview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)viewMapButton:(id)sender
{
    NSLog(@"view map button....");
    [self.view addSubview:mapContainer];
}

-(IBAction)yesAttendAction:(id)sender
{
    [self resetButton:0];
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:globalEvent.eventID:@"yes":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    [rc release];

}

-(IBAction)noAttendAction:(id)sender
{
    [self resetButton:1];    
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:globalEvent.eventID:@"no":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    [rc release];

}

-(IBAction)maybeAttendAction:(id)sender
{
    [self resetButton:2];    
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:globalEvent.eventID:@"maybe":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    [rc release];
}

-(IBAction)closeMap:(id)sender
{
    [self.mapContainer removeFromSuperview];
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)resetButton:(int)index
{
    if (index==0)
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];        
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        NSLog(@"0");
    }
    else if (index==1) 
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];        
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
                NSLog(@"1");
    }
    else if (index==2)
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
                NSLog(@"2");
    }
}

-(IBAction)guestList:(id)sender
{
    NSLog(@"guest list");
}

-(IBAction)saveCustom:(id)sender
{
    if (([selectedFriends count]==0) &&([selectedCircleCheckArr count]==0))
    {
        [UtilityClass showAlert:@"" :@"Please select friends or circles"];
    }
    else {
        RestClient *rc=[[RestClient alloc] init];
        NSMutableArray *circleIDList = [[NSMutableArray alloc] init];
        NSMutableArray *friendsIDList = [[NSMutableArray alloc] init];
        for (int i=0; i<[selectedFriends count]; i++)
        {
            [globalEvent.permittedUsers addObject:((UserFriends *)[selectedFriends objectAtIndex:i]).userId];
            NSLog(@"userID %@",((UserFriends *)[selectedFriends objectAtIndex:i]).userId);
            [friendsIDList addObject:((UserFriends *)[selectedFriends objectAtIndex:i]).userId];
        }
        for (int i=0; i<[selectedCircleCheckArr count]; i++)
        {
            UserCircle *circle=[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row];
            NSString *circleId=circle.circleID;
            [globalEvent.permittedCircles addObject:circleId];
            NSLog(@"circleID %@",circleId);
            [circleIDList addObject:circleId];
        }
        
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate.window setUserInteractionEnabled:NO];
        
        [rc inviteMoreFriendsEvent:globalEvent.eventID :friendsIDList :circleIDList :@"Auth-Token" :smAppDelegate.authToken];
        [customView removeFromSuperview];
        [friendsIDList release];
        [circleIDList release];
        [rc release];
    }
}

-(IBAction)cancelCustom:(id)sender
{
    [customView removeFromSuperview];
}

-(IBAction)invitePeople:(id)sender
{
     [self.view addSubview:customView];
}

-(IBAction)deleteEvent:(id)sender
{
    NSLog(@"delete event");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    
    [smAppDelegate showActivityViewer:self.view];    
    [smAppDelegate.window setUserInteractionEnabled:NO];

    RestClient *rc=[[[RestClient alloc] init] autorelease];
    Event *aEvent=globalEvent;
    NSLog(@"aEvent.eventID: %@  smAppDelegate.authToken: %@",aEvent.eventID,smAppDelegate.authToken);
    [rc deleteEventById:aEvent.eventID:@"Auth-Token":smAppDelegate.authToken];
}

-(IBAction)editEvent:(id)sender
{
    detNotfCounter=0;
    NSLog(@"edit event");
    globalEditEvent=globalEvent;
    editFlag=true;
    isFromVenue=FALSE;
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CreateEventViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"createEvent"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void)deleteEventDone:(NSNotification *)notif
{
    notfCounter++;
    if (notfCounter==1)
    {
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];
        NSLog(@"dele %@",[notif object]);
        [UtilityClass showAlert:@"Social Maps" :@"Event Deleted"];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)inviteFriendsEventDone:(NSNotification *)notif
{
    inviteNotfCounter++;
    if (inviteNotfCounter==1)
    {
        NSLog(@"invited %@",[notif object]);
        [UtilityClass showAlert:@"Social Maps" :@"Guest invited"];
    }
    [smAppDelegate hideActivityViewer];
    [self hideActivity];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}

-(void)loadScrollView
{
    for (int i=0; i<[imageArr count]; i++)
    {
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(i*60, 0, 60, 65)];
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [imgView setImage:[UIImage imageNamed:@""]];
        UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
        [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [name setNumberOfLines:0];
        [name setText:@"Bonolota Sen"];
        [name setBackgroundColor:[UIColor clearColor]];
        [aView addSubview:imgView];
        [aView addSubview:name];
        [guestScrollView addSubview:aView];
        [aView release];
        [name release];
        [imgView release];
        NSLog(@" :%d",i*60);
    }
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if ([animationID isEqualToString:@"slideMenu"])
    {
        UIView *sq = (UIView *) context;
        [sq removeFromSuperview];
        [sq release];
    }
}

- (IBAction)menuTapped 
{
    NSLog(@"Menu tapped");
    CGRect frame = self.rsvpView.frame;
    CGRect detframe = self.detailView.frame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    [UIView beginAnimations:@"slideMenu" context:self.rsvpView];    
    if(menuOpen) 
    {
        frame.origin.y = -80;
        detframe.origin.y=171;
        menuOpen = NO;
    }
    else
    {
        frame.origin.y = 171;
        detframe.origin.y=214;
        menuOpen = YES;
    }    
    self.rsvpView.frame = frame;
    self.detailView.frame=detframe;
    [UIView commitAnimations];
}

//lazy scroller

-(void) reloadScrolview
{
    NSLog(@"event detail in scroll init %d",[imagesName count]);
    if (isBackgroundTaskRunning==TRUE)  
    {
    NSLog(@"event detail isBackgroundTaskRunning %i",isBackgroundTaskRunning);
    int x=0; //declared for imageview x-axis point    
    
    NSArray* subviews = [NSArray arrayWithArray: guestScrollView.subviews];
    for (UIView* view in subviews) 
    {
        if([view isKindOfClass :[UIView class]])
        {
            [view removeFromSuperview];
        }
        else if([view isKindOfClass :[UIImageView class]])
        {
        }
    }
    guestScrollView.contentSize=CGSizeMake([imagesName count]*65, 65);
    NSLog(@"guestScrollView.contentSize %@",NSStringFromCGSize(guestScrollView.contentSize));
    for(int i=0; i<[imagesName count];i++)       
        
    {
        if(i< [imagesName count])
        { 
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            
            if(!isDragging_msg && !isDecliring_msg)
                [imgView loadFromURL:[NSURL URLWithString:[imagesName objectAtIndex:i]]];
            
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
            [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            [name setNumberOfLines:0];
            
            if ([nameArrEventDetail count]-1>=i) {
                [name setText:[nameArrEventDetail objectAtIndex:i]];
            }
            
            [name setBackgroundColor:[UIColor clearColor]];
            imgView.userInteractionEnabled = YES;           
            imgView.tag = i;           
            imgView.exclusiveTouch = YES;           
            imgView.clipsToBounds = NO;           
            imgView.opaque = YES;   
            imgView.exclusiveTouch = YES;
            imgView.clipsToBounds = NO;
            imgView.opaque = YES;

            imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            if ([globalEvent.yesArr containsObject:[idArr objectAtIndex:i]] ||[[idArr objectAtIndex:i] isEqualToString:globalEvent.owner])
            {
            imgView.layer.borderColor=[[UIColor greenColor] CGColor];
            }
            else if([globalEvent.noArr containsObject:[idArr objectAtIndex:i]]) 
            {
            imgView.layer.borderColor=[[UIColor redColor] CGColor];
            }
            else
            {
            imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            }
            imgView.userInteractionEnabled=YES;
            imgView.layer.borderWidth=1.5;
            imgView.layer.masksToBounds = YES;
            [imgView.layer setCornerRadius:7.0];
            [aView addSubview:imgView];
            [aView addSubview:name];
            [guestScrollView addSubview:aView];
            [imgView release];
            [aView release];
            [name release];
        }       
            x+=65;   
    }
    }
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBackgroundTaskRunning==TRUE) 
    {
    int index = [path intValue];
    NSString *Link = [imagesName objectAtIndex:index];
    //Start download image from url
        UIImage *img = [UIImage imageNamed:@"blank.png"];
        if ([Link isEqual:[NSString class]])
        {
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        }
    if((img) && ([dicImages_msg objectForKey:[imagesName objectAtIndex:index]]==NULL))
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:[imagesName objectAtIndex:index]];
        NSLog(@"img: %@    %@",img,[imagesName objectAtIndex:index]);
        [self reloadScrolview];
        
    }
    // Now, we need to reload scroll view to load downloaded image
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging_msg = TRUE;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = TRUE;
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


//table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [circleList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"circleTableCell";
    
    SelectCircleTableCell *cell = [circleTableView
                                   dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if ([[circleList objectAtIndex:indexPath.row] isEqual:[NSNull null]]) 
    {
        cell.circrcleName.text=[NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
    }
    else 
    {
        [((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count];
        cell.circrcleName.text=[NSString stringWithFormat:@"%@ (%d)",[circleList objectAtIndex:indexPath.row],[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
    }
    
    if ([selectedCircleCheckArr containsObject:indexPath]) 
    {
        [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    
    [cell.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)handleTableViewCheckbox:(id)sender
{
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleTableView indexPathForCell:clickedCell];
    if ([selectedCircleCheckArr containsObject:clickedButtonPath])
    {
        [selectedCircleCheckArr removeObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    else
    {
        [selectedCircleCheckArr addObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    NSLog(@"selectedCircleCheckArr: %@",selectedCircleCheckArr);    
}
//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    if (searchBar==friendSearchbar)
    {
        searchText=friendSearchbar.text;
        
        if ([searchText length]>0) 
        {
            [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
            NSLog(@"searchText  %@",searchText);
        }
        else
        {
            searchTexts=@"";
            [FriendList removeAllObjects];
            FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
            [self reloadFriendsScrollview];
        }
    }
    else
    {
        
    }
    searchTexts=friendSearchbar.text;
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchTexts=@"";
        [FriendList removeAllObjects];
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadFriendsScrollview];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    
    searchTexts=friendSearchbar.text;
    [UtilityClass beganEditing:(UIControl *)friendSearchbar];
    
    
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
    [UtilityClass endEditing];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    friendSearchbar.text=@"";
    searchTexts=@"";    
    [FriendList removeAllObjects];
    FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
    [self reloadFriendsScrollview];
    [friendSearchbar resignFirstResponder];
    NSLog(@"3");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    {
        NSLog(@"Search button clicked");
        searchTexts=friendSearchbar.text;
        [self searchResult];
        [friendSearchbar resignFirstResponder];    
    }
}

-(void)searchResult
{
    [self loadFriendsNCircleData];
    searchTexts = friendSearchbar.text;
    NSLog(@"in search method..");
    
    [FriendList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchbar.text=@"";
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        NSLog(@"filteredList999 %@ %@  %d  %d  imageDownloadsInProgress: %@",FriendList,friendListArr,[FriendList count],[friendListArr count], dicImages_msg);
        
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [FriendList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
    
    NSLog(@"filteredList %@ %@  %d  %d  imageDownloadsInProgress: %@",FriendList,friendListArr,[FriendList count],[friendListArr count], dicImages_msg);
    [self reloadFriendsScrollview];
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

- (void)getEventDetailDone:(NSNotification *)notif
{
    detNotfCounter++;
    globalEvent=[notif object];
    NSLog(@"Detail globalEvent: %@ %@",globalEvent.eventID,globalEvent.eventDate.date);
    
    NSLog(@"[globalEvent.guestList count] %d",[globalEvent.guestList count]);
        
    {
        UserFriends *frnd;
        [imagesName removeAllObjects];
        [nameArrEventDetail removeAllObjects];
        [idArr removeAllObjects];
        
        for (int i=0; i<[globalEvent.guestList count]; i++)
        {
            frnd=[globalEvent.guestList objectAtIndex:i];
            NSLog(@"UserFriendsImg %@ frnd %@",frnd.imageUrl,frnd);
            if ((frnd.imageUrl==NULL)||[frnd.imageUrl isEqual:[NSNull null]])
            {
                NSLog(@"img url null %d",i);
            }
            else
            {
                NSLog(@"img url not null %d",i);            
            }
            [imagesName addObject:frnd.imageUrl];
            [nameArrEventDetail addObject:frnd.userName];
            [idArr addObject:frnd.userId];
        }

        NSLog(@"reloading view");
        [self loadFriendsNCircleData];
        [self initView];
        [self reloadFriendsScrollview];
        [self reloadScrolview];
    }
    NSLog(@"detNotfCounter: %d  globalEvent.guestList: %@ %d",detNotfCounter, globalEvent.guestList,[imagesName count]);
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self hideActivity];
    NSLog(@"guestScrollView size %@ %@",NSStringFromCGSize(guestScrollView.contentSize),imagesName);
}

-(void)loadScrollData
{
    
    [imagesName removeAllObjects];
    [nameArrEventDetail removeAllObjects];
    [idArr removeAllObjects];
    
    for (int i=0; i<[globalEvent.guestList count]; i++)
    {
        UserFriends *frnd=[globalEvent.guestList objectAtIndex:i];
        NSLog(@"UserFriendsImg %@ frnd %@",frnd.imageUrl,frnd);
        if ((frnd.imageUrl==NULL)||[frnd.imageUrl isEqual:[NSNull null]])
        {
            NSLog(@"img url null %d",i);
        }
        else
        {
            NSLog(@"img url not null %d",i);            
        }
        [imagesName addObject:frnd.imageUrl];
        [nameArrEventDetail addObject:frnd.userName];
        [idArr addObject:frnd.userId];
    }

}

-(IBAction)segmentChanged:(id)sender
{
    if (segmentControl.selectedSegmentIndex==0) {
        [circleTableView setHidden:YES];
        [frndsScrollView setHidden:NO];
        [friendSearchbar setHidden:NO];
    }
    else if (segmentControl.selectedSegmentIndex==1) {
        [circleTableView setHidden:NO];
        [frndsScrollView setHidden:YES];
        [friendSearchbar setHidden:YES];
    }
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

-(void)viewWillDisappear:(BOOL)animated
{
    isBackgroundTaskRunning=FALSE;
    detNotfCounter=0;
    //[dicImages_msg removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_EVENT_DETAIL_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DELETE_EVENT_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_INVITE_FRIENDS_EVENT_DONE object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [backgroundImageView release];
    [super dealloc];
}
@end
