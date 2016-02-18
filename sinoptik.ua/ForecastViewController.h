//
//  ForecastViewController.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <UIKit/UIKit.h>

#import "ILTranslucentView.h"

#import "ForecastManager.h"
#import "PlacesDataSource.h"
#import "AssetsManager.h"

#import "HourlyForecastTableViewCell.h"
#import "SummaryForecastTableViewCell.h"

@interface ForecastViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property HourlyForecast *currentCast;

- (void) setPlace:(NSArray *) p date:(NSDate *) d;
- (void) populate:(DailyForecast *) cast;

@end
