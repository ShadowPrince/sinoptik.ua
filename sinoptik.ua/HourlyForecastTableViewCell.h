//
//  HourlyForecastTableViewCell.h
//  
//
//  Created by shdwprince on 9/9/15.
//
//

#import <UIKit/UIKit.h>
#import "UIImage-Extensions.h"

#import "AssetsManager.h"
#import "Forecast.h"

@interface HourlyForecastTableViewCell : UITableViewCell

- (void) populate:(HourlyForecast *) cast;
- (void) setupSeparator;
- (void) setCurrent;
- (void) setHeader;

@end
