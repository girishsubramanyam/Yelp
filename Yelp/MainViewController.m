//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "YelpViewCell.h"
#import "FilterViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray* businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchBar* searchBar;
@property (assign, nonatomic) BOOL isSearch;
@property (nonatomic, strong) YelpViewCell *prototypeCell;
@property (nonatomic, strong) NSDictionary* appliedFilters;

- (void)searchBusinessesWithQuery:(NSString*)term params:(NSDictionary*) params;

@end

@implementation MainViewController

#pragma mark - Lifecycle hooks
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self searchBusinessesWithQuery:@"Restaurant" params:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YelpViewCell" bundle:nil] forCellReuseIdentifier:@"YelpViewCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.title = @"Yelp";
    
    self.searchBar = [[UISearchBar alloc] init];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    // customize navigation bar link colors?
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation Bar button
- (void) onFilterButton {
    FilterViewController *vc = [[FilterViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.delegate = self;
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - FilterViewController delegate
- (void) filterViewController:(FilterViewController *)filterViewController filtersDidChange:(NSDictionary *)filters {
    NSLog(@"Filter applied %@", filters);
    self.appliedFilters = filters;
    [self searchBusinessesWithQuery:self.searchBar.text params:filters];
}

#pragma mark - Table View methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YelpViewCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.prototypeCell.business = self.businesses[indexPath.row];
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (YelpViewCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"YelpViewCell"];
    }
    return _prototypeCell;
}

#pragma mark - UISearchBar methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    
    NSString *searchText = searchBar.text;
    if (searchText.length == 0) {
        self.isSearch = NO;
        [self.tableView reloadData];
    } else {
        self.isSearch = YES;
        NSDictionary *params = self.appliedFilters.count > 0 ? self.appliedFilters : nil;
        [self searchBusinessesWithQuery:searchText params:params];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    self.isSearch = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchBar setShowsCancelButton:YES animated:NO];
}

#pragma mark - Custom methods
- (void)searchBusinessesWithQuery:(NSString*)term params:(NSDictionary*) params {
    [self.client searchWithTerm:term params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray* results = response[@"businesses"];
        self.businesses = [Business getBusinesses:results];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

@end
