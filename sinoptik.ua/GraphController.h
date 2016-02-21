//
//  TemperatureGraphController.h
//  sinoptik.ua
//
//  Created by shdwprince on 2/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forecast.h"

@interface GraphController : NSObject

- (NSArray *) temperatureGraphDataFor:(Forecast *) cast;

@end
