//
//  Forecast.m
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import "Forecast.h"

#pragma mark - hourly forecast

@implementation HourlyForecast
@synthesize clouds, rain, temperature, pressure, humidity, wind_speed, rain_probability, hour;

- (NSString *) description {
    return [NSString stringWithFormat:@"{%d, (rain: %d, clouds: %d), pressure %d, hum %d, wnd %@%f, prob. %d}",
            self.temperature,
            self.rain,
            self.clouds,
            self.pressure,
            self.humidity,
            self.wind_directions[self.wind_direction],
            self.wind_speed,
            self.rain_probability];
}

- (void) setWindDirection:(NSString *)wind_direction {
    self.wind_direction = [HourlyForecast.wind_directions indexOfObject:wind_direction];
}

+ (NSArray *) wind_directions {
    return @[@"N", @"NE", @"E", @"SE", @"S", @"SW", @"W", @"NW", @"Z"];
}

#pragma mark coding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.temperature = [aDecoder decodeIntForKey:@"temperature"];
    self.rain = [aDecoder decodeIntForKey:@"rain"];
    self.clouds = [aDecoder decodeIntForKey:@"clouds"];
    self.pressure = [aDecoder decodeIntForKey:@"pressure"];
    self.humidity = [aDecoder decodeIntForKey:@"humidity"];
    self.wind_speed = [aDecoder decodeFloatForKey:@"wind_speed"];
    self.wind_direction = [aDecoder decodeIntForKey:@"wind_direction"];
    self.rain_probability = [aDecoder decodeIntForKey:@"rain_probability"];
    self.hour = [aDecoder decodeIntForKey:@"hour"];

    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.temperature forKey:@"temperature"];
    [aCoder encodeInt:self.rain forKey:@"rain"];
    [aCoder encodeInt:self.clouds forKey:@"clouds"];
    [aCoder encodeInt:self.pressure forKey:@"pressure"];
    [aCoder encodeInt:self.humidity forKey:@"humidity"];
    [aCoder encodeFloat:self.wind_speed forKey:@"wind_speed"];
    [aCoder encodeInt:self.wind_direction forKey:@"wind_direction"];
    [aCoder encodeInt:self.rain_probability forKey:@"rain_probability"];
    [aCoder encodeInt:self.hour forKey:@"hour"];
}

@end

#pragma mark - daily forecast

@implementation DailyForecast
@synthesize hourlyForecast, daylight, summary;

- (NSString *) description {
    return [NSString stringWithFormat:@"%@\n    %@, (%@-%@), %d others",
            self.summary,
            [self.hourlyForecast.allValues.firstObject description],
            self.daylight.firstObject,
            self.daylight.lastObject,
            self.hourlyForecast.count];
}

- (NSArray *) hours {
    return [self.hourlyForecast.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

- (instancetype) init {
    self = [super init];
    self.hourlyForecast = [NSMutableDictionary new];
    self.daylight = @[];
    return self;
}

#pragma mark coding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.hourlyForecast = [aDecoder decodeObject];
    self.daylight = [aDecoder decodeObject];
    self.summary = [aDecoder decodeObject];

    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.hourlyForecast];
    [aCoder encodeObject:self.daylight];
    [aCoder encodeObject:self.summary];
}
@end

#pragma mark - forecast

@interface Forecast ()
@property NSDateFormatter *formatter;
@end@implementation Forecast
@synthesize dailyForecasts;

- (instancetype) init {
    self = [super init];
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"yyyy-MM-dd";
    self.dailyForecasts = [NSMutableDictionary new];
    return self;
}

- (NSString *) description {
    NSArray *keys = [self.dailyForecasts.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];

    NSMutableString *buff = [NSMutableString stringWithFormat:@"%@: {\n", [super description]];
    for (NSDate *key in keys) {
        [buff appendFormat:@"  %@: %@\n", [self.formatter stringFromDate:key], self.dailyForecasts[key]];
    }

    return [buff stringByAppendingString:@"}"];
}

- (DailyForecast *) dailyForecastFor:(NSDate *)date {
    return self.dailyForecasts[[self.formatter dateFromString:[self.formatter stringFromDate:date]]];
}

#pragma mark coding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.dailyForecasts = [aDecoder decodeObject];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.dailyForecasts];
}

@end
