//
//  PlacesViewController.h
//  
//
//  Created by shdwprince on 9/7/15.
//
//

#import <UIKit/UIKit.h>
#import "PlacesDataSource.h"
#import "SearchManager.h"

@interface PlacesViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource>
@property int selected_index;

@end
