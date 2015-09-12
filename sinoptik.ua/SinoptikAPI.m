//
//  SinoptikAPI.m
//  
//
//  Created by shdwprince on 9/7/15.
//
//

#import "SinoptikAPI.h"

@interface SinoptikAPI ()
@property NSURLSession *session;
@property SinoptikResponseParser *parser;
@end@implementation SinoptikAPI

- (instancetype) init {
    self = [super init];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.parser = [[SinoptikResponseParser alloc] init];

    return self;
}

+ (instancetype) api {
    static SinoptikAPI *instance = nil;

    if (!instance)
        instance = [[SinoptikAPI alloc] init];

    return instance;
}

// synchronous loading in NSOperation
- (NSArray *) searchPlaces:(NSString *) query {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSData *data = [NSData dataWithContentsOfURL:[self url:@"/search.php?q=%@", query]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if ([response isEqualToString:@""])
        return @[];

    NSMutableArray *result = [NSMutableArray new];

    for (NSString *part in [response componentsSeparatedByString:@"\n"]) {
        [result addObject:[part componentsSeparatedByString:@"|"]];
    }

    return result;
}

// synchronous loading in NSOperation
- (Forecast *) forecastFor:(NSString *) key {
    Forecast *forecast = [[Forecast alloc] init];

    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";

    NSTimeInterval day = 60 * 60 * 24;
    NSDate *date = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    date = [date dateByAddingTimeInterval:-day];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    for (int i = 0; i < 10; i++) {
        date = [date dateByAddingTimeInterval:day];
        NSData *forecastData = [self apiForecastFor:[NSString stringWithFormat:@"%@/%@", key, [formatter stringFromDate:date]]];
        if (forecastData.length) {
            DailyForecast *cast = [self.parser parseForecast:forecastData];

            forecast.dailyForecasts[date] = cast;
        }

        if ([[NSOperationQueue currentQueue] isSuspended]) {
            forecast.dailyForecasts = [NSMutableDictionary new];
            break;
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 

    return forecast.dailyForecasts.count ? forecast : nil;
}

// synchronous loading in NSOperation
- (NSData *) imageForForecast:(HourlyForecast *) cast ofSize:(SinoptikImageSize) size time:(SinoptikTime) time {
    NSString *format = [size isEqualToString:SinoptikImageSizeBig] ?  @"jpg" : @"gif";
    NSString *stringUrl = [NSString stringWithFormat:@"http://sinst.fwdcdn.com/img/weatherImg/%@/%@%d%d0.%@",
                           size,
                           time,
                           cast.clouds,
                           cast.rain,
                           format];
    return [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]] returningResponse:nil error:nil];
}

# pragma mark private methods

- (NSData *) apiForecastHeadersFor:(NSString *) key {
    return [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[self url:@"/%@", key]] returningResponse:nil error:nil];
}

- (NSData *) apiForecastFor:(NSString *) query {
    NSHTTPURLResponse *resp;

    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[self url:@"/%@?ajax=GetForecast", query]] returningResponse:&resp error:nil];
//    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/2015-09-08.html"]] returningResponse:&resp error:nil];


    if (resp.statusCode == 200)
        return data;
    else
        return nil;
}

- (NSURL *) url:(NSString *) _args, ... {
    va_list args;
    va_start(args, _args);
    NSString *suffix = [[NSString alloc] initWithFormat:_args arguments:args];
    va_end(args);
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://sinoptik.ua%@", [suffix stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

@end
