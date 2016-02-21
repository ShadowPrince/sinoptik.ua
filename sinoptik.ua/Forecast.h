//
//  Forecast.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <Foundation/Foundation.h>

@interface HourlyForecast : NSObject <NSCoding>
@property int clouds;
@property int rain;
@property char temperature;
@property char feelslikeTemperature;
@property int pressure;
@property int humidity;
@property float wind_speed;
@property (nonatomic) int wind_direction;
@property int rain_probability;
@property int hour;

@property (nonatomic) NSArray *wind_directions;

+ (NSArray *) wind_directions;

- (void) setWindDirection:(NSString *) output;
@end

@interface DailyForecast : NSObject <NSCoding>
@property NSArray *daylight;
@property NSString *summary;
@property NSMutableDictionary *hourlyForecast;
@property NSDate *last_update;

- (NSArray *) hours;
- (HourlyForecast *) forecastFor:(int) hour;
- (HourlyForecast *) middayForecast;
- (HourlyForecast *) morningForecast;
- (HourlyForecast *) dayForecast;
- (HourlyForecast *) nightForecast;

@end

@interface Forecast : NSObject <NSCoding>
@property NSMutableDictionary *dailyForecasts;

- (NSArray<NSDate *> *) dates;
- (DailyForecast *) dailyForecastFor:(NSDate *) date;

@end
