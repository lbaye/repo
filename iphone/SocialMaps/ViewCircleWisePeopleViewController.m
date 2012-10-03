//
//  ViewCircleWisePeopleViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ViewCircleWisePeopleViewController.h"
#import "SectionInfo.h"
#import "SectionHeaderView.h"
#import "CircleListTableCell.h"
#import "UserCircle.h"
#import "LocationItemPeople.h"
#import "Globals.h"
#import "UserFriends.h"
#import "Constants.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "SelectCircleTableCell.h"
#pragma mark -
#pragma mark EmailMenuItem


@interface EmailMenuItem : UIMenuItem
@property (nonatomic, strong) NSIndexPath* indexPath;
@end

@implementation EmailMenuItem
@synthesize indexPath;
@end


#pragma mark -
#pragma mark TableViewController


@interface ViewCircleWisePeopleViewController ()
@property (nonatomic, strong) NSMutableArray* sectionInfoArray;
@property (nonatomic, strong) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;

// Use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously.
@property (nonatomic, assign) NSInteger uniformRowHeight;

-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath;

-(void)emailMenuButtonPressed:(UIMenuController*)menuController;
-(void)sendEmailForEntryAtIndexPath:(NSIndexPath*)indexPath;

@end

#define DEFAULT_ROW_HEIGHT 100
#define HEADER_HEIGHT 45

@implementation ViewCircleWisePeopleViewController
@synthesize circleTableView,circleSearchBar;
@synthesize userCircle=userCircle_, sectionInfoArray=sectionInfoArray_, circleListTableCell=newsCell_, pinchedIndexPath=pinchedIndexPath_, uniformRowHeight=rowHeight_, openSectionIndex=openSectionIndex_, initialPinchHeight=initialPinchHeight_;

@synthesize circleCreateView,circleSelectTableView,circleNameTextField;
AppDelegate *smAppDelegate;
-(BOOL)canBecomeFirstResponder {
    
    return YES;
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    userCircle_=circleListDetailGlobalArray;
    // add people list here
    NSLog(@"circleListDetailGlobalArray %@",circleListDetailGlobalArray);
    // Add a pinch gesture recognizer to the table view.
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.circleTableView addGestureRecognizer:pinchRecognizer];
    
    // Set up default values.
    self.circleTableView.sectionHeaderHeight = HEADER_HEIGHT;
	/*
     The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
     */
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    RestClient *rc=[[RestClient alloc] init];
    [rc getAllCircles:@"Auth-Token" :smAppDelegate.authToken];
    rowHeight_ = DEFAULT_ROW_HEIGHT;
    openSectionIndex_ = NSNotFound;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllCircleDone:) name:NOTIF_GET_ALL_CIRCLES_DONE object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
//    [circleCreateView removeFromSuperview];
	
    /*
     Check whether the section info array has been created, and if so whether the section count still matches the current section count. In general, you need to keep the section info synchronized with the rows and section. If you support editing in the table view, you need to appropriately update the section info during editing operations.
     */
	if ((self.sectionInfoArray == nil) || ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.circleTableView])) {
		
        // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		//DATA SOURCE IS HERE
		for (UserCircle *userCircle in userCircle_)
        {
			
			SectionInfo *sectionInfo = [[SectionInfo alloc] init];
			sectionInfo.userCircle = userCircle;
			sectionInfo.open = NO;
			
            NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
			NSInteger countOfQuotations = [[sectionInfo.userCircle friends] count];
			for (NSInteger i = 0; i < countOfQuotations; i++)
            {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
			NSLog(@"play.name %@ play.quotations %@",userCircle.circleName,userCircle.friends);
			[infoArray addObject:sectionInfo];
		}
		
		self.sectionInfoArray = infoArray;
	}
	
}

-(IBAction)addCircleAction:(id)sender
{
    [circleCreateView removeFromSuperview];
}

-(IBAction)okAction:(id)sender
{
    [circleCreateView removeFromSuperview];    
}

-(IBAction)cancelAction:(id)sender
{
    [circleCreateView removeFromSuperview];    
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    // To reduce memory pressure, reset the section info array if the view is unloaded.
	self.sectionInfoArray = nil;
}


#pragma mark Table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (tableView==self.circleSelectTableView) 
    {
        return 1;
    }
    else
    {
        return [userCircle_ count];
    }
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.circleSelectTableView) 
    {
        return [circleListDetailGlobalArray count];
    }
    else
    {
        
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
        NSInteger numStoriesInSection = [[sectionInfo.userCircle friends] count];
        
        return sectionInfo.open ? numStoriesInSection : 0;
    }
}


-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    
    static NSString *CellIdentifier = @"circleTableCell";
    SelectCircleTableCell *cell2 = [self.circleSelectTableView
                                    dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell2)
    {
        cell2 = [[SelectCircleTableCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier];
    }
    NSString *circleName;
    if (![((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).circleName isEqual:[NSNull null]])
    {
        circleName = [NSString stringWithFormat:@"%@ (%d)",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).circleName,[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).friends count]];
        cell2.circrcleName.text=circleName;
    }
    else
    {
        circleName = [NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).friends count]];
        
    }
    
    [cell2.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
    static NSString *QuoteCellIdentifier = @"circleListTableCell";
    
    CircleListTableCell *cell = (CircleListTableCell*)[self.circleTableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
    
    if (!cell) {
        
        UINib *quoteCellNib = [UINib nibWithNibName:@"CircleListTableCell" bundle:nil];
//        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = [[CircleListTableCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:QuoteCellIdentifier];
        cell = self.circleListTableCell;
        self.circleListTableCell = nil;
        
        if ([MFMailComposeViewController canSendMail]) {
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            [cell addGestureRecognizer:longPressRecognizer];
        }
		else {
			NSLog(@"Mail not available");
		}
    }
    
//    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
//    UserFriends *userFrnd=[sectionInfo.userCircle.friends objectAtIndex:indexPath.row];
//    UserCircle *circle=[circleListDetailGlobalArray objectAtIndex:indexPath.section];
//    UserFriends *userFrnd=[circle.friends objectAtIndex:indexPath.row];
//    NSLog(@"userFrnd %@ %d index: %@",userFrnd,[sectionInfo.userCircle.friends count],indexPath);
//    cell.firstNameLabel.text=userFrnd.userName;
//    if (userFrnd.statusMsg)
    {
//        cell.addressLabel.text=userFrnd.statusMsg;
    }
//    cell.distanceLabel.text=[NSString stringWithFormat:@"%.2lfm",userFrnd.distance];
    [cell.inviteButton addTarget:self action:@selector(addToCircle:) forControlEvents:UIControlEventTouchUpInside];
    [cell.inviteButton addTarget:self action:@selector(removeFromCircle:) forControlEvents:UIControlEventTouchUpInside];
    cell.showOnMapButton.hidden=YES;
    cell.profilePicImgView.image=[UIImage imageNamed:@"thum.png"];
    cell.coverPicImgView.image=[UIImage imageNamed:@"cover_pic_default.png"];
//    if ([userFrnd.regMedia isEqualToString:@"fb"])
    {
        cell.regStsImgView.image=[UIImage imageNamed:@"icon_facebook.png"];
    }
//    else
    {
        cell.regStsImgView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
    }
    //    cell.actAndSceneLabel.text=@"actAndScene";
    //    cell.quotationTextView.text=@"Quotation";
    if (tableView==self.circleSelectTableView)
    {
        NSLog(@"circle selection cell");
        return cell2;
    }
    NSLog(@"circle expandable cell");
    return cell;
}


-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    /*
     Create the section header views lazily.
     */
    if (tableView==self.circleTableView) {
        NSLog(@"self.sectionInfoArray %@",self.sectionInfoArray);
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
        if (!sectionInfo.headerView) {
            NSString *circleName;
            if (![((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).circleName isEqual:[NSNull null]]) 
            {
                circleName = [NSString stringWithFormat:@"%@ (%d)",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).circleName,[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).friends count]];
            }
            else
            {
                circleName = [NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).friends count]];
                
            }
            NSLog(@"circleName: %@",circleName);
            sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.circleTableView.bounds.size.width, HEADER_HEIGHT) title:circleName section:section delegate:self];
        }
        
        return sectionInfo.headerView;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (tableView==circleTableView) {
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
        return [[sectionInfo objectInRowHeightsAtIndex:indexPath.row] floatValue];
    }
    else
    {
        return 44.0;
    }
    // Alternatively, return rowHeight.
}


-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"indexPath %@",indexPath);
}


#pragma mark Section header delegate

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionOpened];
	NSLog(@"sectionInfo: h %@ %d",sectionInfo.headerView,sectionOpened);
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.userCircle.friends count];
    NSLog(@"countOfRowsToInsert: %d %d",countOfRowsToInsert,[sectionInfo countOfRowHeights]);
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        NSLog(@"[NSIndexPath indexPathForRow:i inSection:sectionOpened] %@",[NSIndexPath indexPathForRow:i inSection:sectionOpened]);
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    NSLog(@"previousOpenSectionIndex %d",previousOpenSectionIndex);
    if (previousOpenSectionIndex != NSNotFound) {
		
        NSLog(@"secInfo %@ %d ",[self.sectionInfoArray objectAtIndex:previousOpenSectionIndex],previousOpenSectionIndex);
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.userCircle.friends count];
        NSLog(@"countOfRowsToDelete %d",countOfRowsToDelete);
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    else
    {
        NSLog(@"section not found");
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    NSLog(@"1");
    // Apply the updates.
    [self.circleTableView beginUpdates];
        NSLog(@"2");
    [self.circleTableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
        NSLog(@"3");
    [self.circleTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
        NSLog(@"4");
    [self.circleTableView endUpdates];
        NSLog(@"5");
    self.openSectionIndex = sectionOpened;
    NSLog(@"6");    
}


-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionClosed];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.circleTableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.circleTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}


#pragma mark Handling pinches


-(void)handlePinch:(UIPinchGestureRecognizer*)pinchRecognizer {
    
    /*
     There are different actions to take for the different states of the gesture recognizer.
     * In the Began state, use the pinch location to find the index path of the row with which the pinch is associated, and keep a reference to that in pinchedIndexPath. Then get the current height of that row, and store as the initial pinch height. Finally, update the scale for the pinched row.
     * In the Changed state, update the scale for the pinched row (identified by pinchedIndexPath).
     * In the Ended or Canceled state, set the pinchedIndexPath property to nil.
     */
    
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pinchLocation = [pinchRecognizer locationInView:self.circleTableView];
        NSIndexPath *newPinchedIndexPath = [self.circleTableView indexPathForRowAtPoint:pinchLocation];
		self.pinchedIndexPath = newPinchedIndexPath;
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:newPinchedIndexPath.section];
        self.initialPinchHeight = [[sectionInfo objectInRowHeightsAtIndex:newPinchedIndexPath.row] floatValue];
        // Alternatively, set initialPinchHeight = uniformRowHeight.
        
        [self updateForPinchScale:pinchRecognizer.scale atIndexPath:newPinchedIndexPath];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateForPinchScale:pinchRecognizer.scale atIndexPath:self.pinchedIndexPath];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) || (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchedIndexPath = nil;
        }
    }
}


-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath && (indexPath.section != NSNotFound) && (indexPath.row != NSNotFound)) {
        
		CGFloat newHeight = round(MAX(self.initialPinchHeight * scale, DEFAULT_ROW_HEIGHT));
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
        [sectionInfo replaceObjectInRowHeightsAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:newHeight]];
        // Alternatively, set uniformRowHeight = newHeight.
        
        /*
         Switch off animations during the row height resize, otherwise there is a lag before the user's action is seen.
         */
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.circleTableView beginUpdates];
        [self.circleTableView endUpdates];
        [UIView setAnimationsEnabled:animationsEnabled];
    }
}


#pragma mark Handling long presses

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    
    /*
     For the long press, the only state of interest is Began.
     When the long press is detected, find the index path of the row (if there is one) at press location.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *pressedIndexPath = [self.circleTableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.circleTableView]];
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            EmailMenuItem *menuItem = [[EmailMenuItem alloc] initWithTitle:@"Email" action:@selector(emailMenuButtonPressed:)];
            menuItem.indexPath = pressedIndexPath;
            menuController.menuItems = [NSArray arrayWithObject:menuItem];
            [menuController setTargetRect:[self.circleTableView rectForRowAtIndexPath:pressedIndexPath] inView:self.circleTableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}


-(void)emailMenuButtonPressed:(UIMenuController*)menuController {
    
    EmailMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        [self sendEmailForEntryAtIndexPath:menuItem.indexPath];
    }
}


-(void)sendEmailForEntryAtIndexPath:(NSIndexPath*)indexPath {
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:self.pinchedIndexPath.section];
    // In production, send the appropriate message.
    NSLog(@"Send email to %@", sectionInfo);
}


-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultFailed) {
        // In production, display an appropriate message to the user.
        NSLog(@"Mail send failed with error: %@", error);
    }
}

-(UserFriends *)getFriendById:(NSString *)userId
{
    for(int i=0; i<[friendListGlobalArray count]; i++)
    {
        if([((UserFriends *)[friendListGlobalArray objectAtIndex:i]).userId isEqualToString:userId])
        {
            return [friendListGlobalArray objectAtIndex:i];
        }
    }
    return [friendListGlobalArray objectAtIndex:[friendListGlobalArray count]-1];
}

- (void)getAllCircleDone:(NSNotification *)notif
{
    NSLog(@"notification: %@",[notif object]);
    for (int i=0; i<[circleListDetailGlobalArray count]; i++)
    {
        NSLog(@"((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).circleName %@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends) ;
        NSLog(@"%@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends);
        for (int c=0; c<[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends count]; c++)
        {
            UserFriends *userFnd= [((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends objectAtIndex:c];
            NSLog(@"userFnd.userName %@",userFnd.userName);
        }
    }
    userCircle_=circleListDetailGlobalArray;
    [self viewWillAppear:NO];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.circleTableView reloadData];
    [self.view setNeedsDisplay];
    [self.circleSelectTableView reloadData];
    [self.circleCreateView setNeedsDisplay];
}

-(void)addToCircle:(id)sender
{
    [self.view addSubview:circleCreateView];
}

-(void)removeFromCircle:(id)sender
{
    [self.view addSubview:circleCreateView];    
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark Memory management


@end
