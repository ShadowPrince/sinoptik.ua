//
//  PlacesViewController.m
//  
//
//  Created by shdwprince on 9/7/15.
//
//

#import "PlacesViewController.h"

@interface PlacesViewController ()
@property PlacesDataSource *places;

@property SearchManager *searchManager;
@property NSArray *searchResults;
//---
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end@implementation PlacesViewController
@synthesize selected_index;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchManager = [SearchManager new];

    self.places = [PlacesDataSource instance];
    self.tableView.dataSource = self.places;
    self.tableView.contentOffset = CGPointMake(0, 44);
}

- (IBAction)editToggleAction:(UIBarButtonItem *)sender {
    if (self.tableView.isEditing) {
        [sender setTitle:NSLocalizedString(@"Edit", @"edit")];
        [self.tableView setEditing:NO animated:YES];
    } else {
        [sender setTitle:NSLocalizedString(@"Done", @"done")];
        [self.tableView setEditing:YES animated:YES];
    }
}

#pragma mark - search

#pragma mark input

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchManager search:searchText callback:^(NSArray *results) {
        self.searchResults = results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchDisplayController.isActive) {
        [self.places addEntry:self.searchResults[indexPath.row]];
        [self.searchDisplayController setActive:NO];
        [self.tableView reloadData];
    } else {
        self.selected_index = indexPath.row;
        [self performSegueWithIdentifier:@"unwindFromPlaces" sender:self];

    }
}

#pragma mark table view

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];

    NSArray *entry = self.searchResults[indexPath.row];
    [(UILabel *) [cell viewWithTag:100] setText:entry[0]];
    [(UILabel *) [cell viewWithTag:101] setText:entry[1]];

    return cell;
}

@end
