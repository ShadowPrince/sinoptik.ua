//
//  AssetsManager.h
//  
//
//  Created by shdwprince on 9/9/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage-Extensions.h"

#import "Forecast.h"
#import "SinoptikAPI.h"

typedef void (^AssetsManagerLoadImageCallback) (UIImage *);

@interface AssetsManager : NSObject

- (void) cancelOperations;

- (void) loadImageFor:(HourlyForecast *) cast
             callback:(AssetsManagerLoadImageCallback) callback;
- (void) loadMediumImageFor:(HourlyForecast *) cast callback:(AssetsManagerLoadImageCallback) callback;
- (void) loadBigImageFor:(HourlyForecast *) cast callback:(AssetsManagerLoadImageCallback) callback;

- (UIImage *) fancyImageFor:(HourlyForecast *) cast;
- (SinoptikTime) sinoptikTimeFor:(HourlyForecast *) cast;

+ (NSArray *) windDirectionalImages;
@end
