//
//  ViewEventDetailViewController.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "ViewEventDetailViewController.h"

@implementation ViewEventDetailViewController
@synthesize eventName,eventDate,eventShortDetail,eventAddress,eventDistance;    
@synthesize yesButton,noButton,maybeButton,descriptionView,guestScrollView,rsvpView,detailView;

NSMutableArray *imageArr;
bool menuOpen=NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageArr=[[NSMutableArray alloc] initWithObjects:@"girl.png",@"girl.png",@"girl.png",@"girl.png",@"girl.png",@"girl.png",@"girl.png",@"girl.png",@"girl.png",@"girl.png", nil];
    
    //    [self loadScrollView];
	// Do any additional setup after loading the view.
    
    guestScrollView.delegate = self;
    dicImages_msg = [[NSMutableDictionary alloc] init];
    ImgesName = [[NSMutableArray alloc] initWithObjects:   
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005482.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005457.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005470.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005463.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005465.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005466.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005469.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005472.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005479.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005484.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005483.jpg",nil ];    
    //set scroll view content size.
    guestScrollView.contentSize=CGSizeMake([ImgesName count]*65, 65);
    
    //reloading scrollview to start asynchronous download.
    [self reloadScrolview]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)viewMapButton:(id)sender
{
    NSLog(@"view map button....");
}

-(IBAction)yesAttendAction:(id)sender
{
    [self resetButton:0];
}

-(IBAction)noAttendAction:(id)sender
{
    [self resetButton:1];    
}

-(IBAction)maybeAttendAction:(id)sender
{
    [self resetButton:2];    
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

-(IBAction)invitePeople:(id)sender
{
    NSLog(@"invite people");    
}

-(IBAction)deleteEvent:(id)sender
{
    NSLog(@"delete event");
}

-(IBAction)editEvent:(id)sender
{
    NSLog(@"edit event");
}

-(void)loadScrollView
{
    guestScrollView.contentSize=CGSizeMake(600, 60);
    for (int i=0; i<[imageArr count]; i++)
    {
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(i*60, 0, 60, 65)];
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [imgView setImage:[UIImage imageNamed:@"girl.png"]];
        UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
        [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [name setNumberOfLines:0];
        [name setText:@"Bonolota Sen"];
        [aView addSubview:imgView];
        [aView addSubview:name];
        [guestScrollView addSubview:aView];
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
    int x=0; //declared for imageview x-axis point    
    int y=0;   
    
    for(int i=0; i<[ImgesName count];i++)       
        
    {
        if(i< [ImgesName count]) 
        { 
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            if([dicImages_msg valueForKey:[ImgesName objectAtIndex:i]]) 
            { 
                //If image available in dictionary, set it to imageview 
                imgView.image = [dicImages_msg valueForKey:[ImgesName objectAtIndex:i]]; 
            } 
            else 
            { 
                if(!isDragging_msg && !isDecliring_msg) 
                    
                {
                    //If scroll view moves set a placeholder image and start download image. 
                    [dicImages_msg setObject:[UIImage imageNamed:@"girl.png"] forKey:[ImgesName objectAtIndex:i]]; 
                    [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                }
                else 
                { 
                    // Image is not available, so set a placeholder image                    
                    imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }               
            }
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
            [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            [name setNumberOfLines:0];
            [name setText:@"Bonolota Sen"];
            imgView.userInteractionEnabled = YES;           
            imgView.tag = i;           
            imgView.exclusiveTouch = YES;           
            imgView.clipsToBounds = NO;           
            imgView.opaque = YES;           
            [aView addSubview:imgView];
            [aView addSubview:name];
            [guestScrollView addSubview:aView];           
        }       
            x+=65;   
    }
}

-(void)DownLoad:(NSNumber *)path
{
    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    NSString *Link = [ImgesName objectAtIndex:index];
    //Start download image from url
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
    if(img)
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:[ImgesName objectAtIndex:index]];
    }
    // Now, we need to reload scroll view to load downloaded image
    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
    [pl release];
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

@end
