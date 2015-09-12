//
//  ForecastViewController.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <UIKit/UIKit.h>

#import "ForecastManager.h"
#import "PlacesDataSource.h"
#import "AssetsManager.h"

#import "HourlyForecastTableViewCell.h"
#import "SummaryForecastTableViewCell.h"

@interface ForecastViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (instancetype) initWithPlace:(NSArray *) place date:(NSDate *) d;

- (void) populate:(DailyForecast *) cast;

@end
