//
//  PlacesDataSource.m
//  
//
//  Created by shdwprince on 9/7/15.
//
//

#import "PlacesDataSource.h"

@implementation PlacesDataSource
@synthesize places;

- (instancetype) init {
    self = [super init];
    places = [self restore];
    if (!places) {
        self.places = [NSMutableArray new];
    }

    return self;
}

+ (instancetype) instance {
    static PlacesDataSource *instance = nil;
    if (!instance)
        instance = [PlacesDataSource new];

    return instance;
}

- (NSMutableArray *) places {
    return places;
}

- (void) setPlaces:(NSArray *)_places {
    places = [_places mutableCopy];

    [self store];
}

- (void) moveEntryFrom:(NSUInteger) source to:(NSUInteger) target {
    id object = self.places[source];
    [places removeObjectAtIndex:source];
    [places insertObject:object atIndex:target];

    [self store];
}

- (void) deleteEntryAt:(NSUInteger) idx {
    [places removeObjectAtIndex:idx];

    [self store];
}

- (void) addEntry:(NSArray *) entry {
    [places addObject:entry];

    [self store];
}

#pragma mark - user defaults

- (void) store {
    [[NSUserDefaults standardUserDefaults] setValue:self.places forKey:@"places"];
}

- (NSMutableArray *) restore {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"places"] mutableCopy];
}

#pragma mark - table 

#pragma mark editing

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteEntryAt:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self moveEntryFrom:sourceIndexPath.row to:destinationIndexPath.row];
}

#pragma mark data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.places.count : 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

        NSArray *entry = self.places[indexPath.row];
        [(UILabel *) [cell viewWithTag:100] setText:[entry firstObject]];
        [(UILabel *) [cell viewWithTag:101] setText:entry[1]];
        
        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:@"End"];
    }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

@end
