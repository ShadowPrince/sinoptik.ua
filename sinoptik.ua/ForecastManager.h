//
//  ForecastManager.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <Foundation/Foundation.h>
#import "SinoptikAPI.h"

@class ForecastManager;

@protocol ForecastManagerDelegate <NSObject>
- (void) forecastManager:(ForecastManager *) manager didReceivedForecast:(Forecast *) cast for:(NSArray *) place;
@end

@interface ForecastManager : NSObject

- (instancetype) initWithDelegate:(id<ForecastManagerDelegate>) delegate;
- (void) requestForecastFor:(NSString *) key;

@end
