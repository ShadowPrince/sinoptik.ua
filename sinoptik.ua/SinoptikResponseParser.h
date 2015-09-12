//
//  SinoptikResponseParser.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <Foundation/Foundation.h>
#import "Forecast.h"
#import "TFHpple.h"

@interface SinoptikResponseParser : NSObject

- (DailyForecast *) parseForecast:(NSData *) htmlData;

@end
