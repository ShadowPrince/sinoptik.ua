//
//  SummaryForecastTableViewCell.h
//  
//
//  Created by shdwprince on 9/13/15.
//
//

#import <UIKit/UIKit.h>
#import "Forecast.h"

@interface SummaryForecastTableViewCell : UITableViewCell

- (void) populate:(DailyForecast *) cast;

@end
