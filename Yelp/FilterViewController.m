//
//  FilterViewController.m
//  Yelp
//
//  Created by Girish Subramanyam on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "SwitchViewCell.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource, SwitchCellViewDelegate>

@property (nonatomic, readonly) NSDictionary* filters;
@property (nonatomic, strong) NSMutableDictionary *activeFilters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* categories;
@property (strong, nonatomic) NSMutableSet* selectedCategories;
@property (strong, nonatomic) NSArray* availableFilters;

- (void) initCategories;
- (void) initAvailableFilters;
@end

@implementation FilterViewController

#pragma mark - Lifecycle hooks
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.selectedCategories = [NSMutableSet set];
        //self.activeFilters = [NSMutableDictionary dictionary];
        [self initCategories];
        [self initAvailableFilters];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.title = @"Filter";
    
    // table delegate
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchViewCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    // customize navigation bar link colors?
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.activeFilters = [defaults objectForKey:@"activeFilters"] ? [defaults objectForKey:@"activeFilters"]: [NSMutableDictionary dictionary];
    self.selectedCategories = [NSMutableSet setWithArray:[defaults objectForKey:@"selectedCategories"]];
    
    CGFloat distanceMeters = [[self.activeFilters valueForKey:@"radius_filter"] floatValue];
    if (distanceMeters > 0) {
        CGFloat distanceMiles = distanceMeters/1600;
        [self.activeFilters setObject:[NSString stringWithFormat:@"%li", (long)[@(distanceMiles) integerValue]] forKey:@"radius_filter"];
    }
}

#pragma mark - Navgation Bar actions
- (void) onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary*)filters {
    NSMutableDictionary* filters = [NSMutableDictionary dictionary];
    if (self.selectedCategories.count > 0) {
        NSMutableArray* categoryNames = [NSMutableArray array];
        for (NSDictionary* dic in self.selectedCategories) {
            [categoryNames addObject:dic[@"code"]];
        }
        NSString *filterString = [categoryNames componentsJoinedByString:@","];
        [filters setObject:filterString forKey:@"category_filter"];
    }
    // Massage the radius data
    NSString *distanceMiles = [self.activeFilters valueForKey:@"radius_filter"];
    if (distanceMiles.length > 0) {
        CGFloat distanceMeters = [distanceMiles floatValue]*1600;
        [self.activeFilters setObject:@(distanceMeters) forKey:@"radius_filter"];
    }
    
    // Add all filters
    [filters addEntriesFromDictionary:self.activeFilters];
    return filters;
}

- (void) onApplyButton {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate filterViewController:self filtersDidChange:self.filters];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.activeFilters forKey:@"activeFilters"];
    [defaults setObject:[self.selectedCategories allObjects] forKey:@"selectedCategories"];
    [defaults synchronize];
}

#pragma mark - SwitchCell delegate
- (void)switchCellView:(SwitchViewCell *)cell valueDidChange:(BOOL)on {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0) { // Deals
        if (on) {
            [self.activeFilters setObject:@true forKey:@"deals_filter"];
        } else {
            [self.activeFilters removeObjectForKey:@"deals_filter"];
        }
    } else if (indexPath.section == 1) { // Sort
        if (on) {
            [self.activeFilters setObject:@(indexPath.row) forKey:@"sort"];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self.activeFilters removeObjectForKey:@"sort"];
        }
    } else if (indexPath.section == 2) { // Radius
        if (on) {
            NSArray *distances = [[self.availableFilters objectAtIndex:indexPath.section] valueForKey:@"value"];
            NSString *selectedDistance = [distances objectAtIndex:indexPath.row];
            [self.activeFilters setObject:selectedDistance forKey:@"radius_filter"];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self.activeFilters removeObjectForKey:@"radius_filter"];
        }
    } else if (indexPath.section == 3) { // Categories
        if (on) {
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }
    }
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.availableFilters.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id value = self.availableFilters[section][@"value"];
    if ([value isKindOfClass:[NSString class]]) {
        return 1;
    } else {
        return [value count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.availableFilters[section][@"name"];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    NSInteger section = indexPath.section;
    NSString *distanceMile;
    id dealsFilter = [self.activeFilters objectForKey:@"deals_filter"];
    id sortFilter = [self.activeFilters valueForKey:@"sort"];
    id radiusFilter = [self.activeFilters valueForKey:@"radius_filter"];
    
    switch (section) {
        case 0: // Deals
            cell.delegate = self;
            cell.on = dealsFilter;
            cell.settingsLabel.text = self.availableFilters[section][@"value"];
            break;
        case 1: // Sort By
            cell.delegate = self;
            cell.on = sortFilter ? ([sortFilter integerValue] == indexPath.row) : false;
            cell.settingsLabel.text = [self.availableFilters[section][@"value"] objectAtIndex:indexPath.row];
            break;
        case 2: // Distance
            cell.delegate = self;
            distanceMile = [self.availableFilters[section][@"value"] objectAtIndex:indexPath.row];
            cell.on = [radiusFilter integerValue] > 0 ? [radiusFilter isEqualToString:distanceMile] : false;
            cell.settingsLabel.text = distanceMile;
            break;
        case 3: //Categories
            cell.delegate = self;
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            cell.settingsLabel.text = self.categories[indexPath.row][@"name"];
            break;
    }
    
    return cell;
}

#pragma mark - private methods
- (void) initAvailableFilters {
    self.availableFilters = @[
                              
                              [NSDictionary dictionaryWithObjectsAndKeys:@"Deals", @"name",
                               @"Show me deals only", @"value", nil],
                              [NSDictionary dictionaryWithObjectsAndKeys:@"Sort By", @"name",
                               @[@"Best Matched", @"Distance", @"Highest Rated"], @"value", nil ],
                              [NSDictionary dictionaryWithObjectsAndKeys:@"Distance", @"name",
                               @[@"1", @"5", @"10", @"20"], @"value", nil ],
                              [NSDictionary dictionaryWithObjectsAndKeys:@"Categories", @"name",
                               self.categories, @"value", nil ]
                              ];
}

- (void) initCategories {
    self.categories = @[
                        @{@"name" : @"Afghan", @"code": @"afghani" },
                        @{@"name" : @"American, New", @"code": @"newamerican" },
                        @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                        @{@"name" : @"Arabian", @"code": @"arabian" },
                        @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                        @{@"name" : @"Barbeque", @"code": @"bbq" },
                        @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                        @{@"name" : @"British", @"code": @"british" },
                        @{@"name" : @"Buffets", @"code": @"buffets" },
                        @{@"name" : @"Burgers", @"code": @"burgers" },
                        @{@"name" : @"Cafes", @"code": @"cafes" },
                        @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                        @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                        @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                        @{@"name" : @"Chinese", @"code": @"chinese" },
                        @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                        @{@"name" : @"Diners", @"code": @"diners" },
                        @{@"name" : @"Dumplings", @"code": @"dumplings" },
                        @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                        @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                        @{@"name" : @"Food Stands", @"code": @"foodstands" },
                        @{@"name" : @"French", @"code": @"french" },
                        @{@"name" : @"German", @"code": @"german" },
                        @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                        @{@"name" : @"Greek", @"code": @"greek" },
                        @{@"name" : @"Halal", @"code": @"halal" },
                        @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                        @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                        @{@"name" : @"Indian", @"code": @"indpak" },
                        @{@"name" : @"International", @"code": @"international" },
                        @{@"name" : @"Italian", @"code": @"italian" },
                        @{@"name" : @"Japanese", @"code": @"japanese" },
                        @{@"name" : @"Kebab", @"code": @"kebab" },
                        @{@"name" : @"Korean", @"code": @"korean" },
                        @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                        @{@"name" : @"Mexican", @"code": @"mexican" },
                        @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                        @{@"name" : @"Night Food", @"code": @"nightfood" },
                        @{@"name" : @"Oriental", @"code": @"oriental" },
                        @{@"name" : @"Pakistani", @"code": @"pakistani" },
                        @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                        @{@"name" : @"Pita", @"code": @"pita" },
                        @{@"name" : @"Pizza", @"code": @"pizza" },
                        @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                        @{@"name" : @"Salad", @"code": @"salad" },
                        @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                        @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                        @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                        @{@"name" : @"Thai", @"code": @"thai" },
                        @{@"name" : @"Vegan", @"code": @"vegan" },
                        @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                        @{@"name" : @"Wraps", @"code": @"wraps" },
                    ];
}

@end
