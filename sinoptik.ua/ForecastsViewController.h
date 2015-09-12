//
//  ForecastsViewController.h
//  
//
//  Created by shdwprince on 9/9/15.
//
//

#import <UIKit/UIKit.h>
#import "ForecastViewController.h"
#import "PlacesViewController.h"

@interface ForecastsViewController : UIViewController<ForecastManagerDelegate, UIScrollViewDelegate>
@property NSUInteger key;

@end
