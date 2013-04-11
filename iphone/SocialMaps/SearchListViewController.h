//
//  SearchListViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on ১১/৪/১৩.
//  Copyright (c) ২০১৩ Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LocationItem.h"

@protocol SearchViewProtocol

-(void)removeSearchView;
-(void)removeSearchViewWithLocation:(LocationItem *)item;

@end

@interface SearchListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SearchViewProtocol>
{
    IBOutlet UITableView *searchTableView;
    NSMutableArray *filteredList;
    NSMutableArray *peopleListArray;
    NSString *searchText;
    IBOutlet UISearchBar *searchBar;
}

@property(nonatomic,retain) IBOutlet UITableView *searchTableView;
@property(nonatomic,retain) id <SearchViewProtocol> delegate;
@property(nonatomic,retain) NSString *searchText;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) NSMutableArray *filteredList;

-(IBAction)cancelSearchAction:(id)sender;

@end
