//
//  TodayViewController.m
//  sinoptik.ua widget
//
//  Created by shdwprince on 2/27/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *delim200;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *delim300;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *delim400;
@property NSArray<NSLayoutConstraint *> *delimeters;

@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property ForecastManager *man;
@property PlacesDataSource *places;

@property NSDate *lastUpdate;
@property NSDateFormatter *formatter, *captionFormatter;
@property Forecast *cast;
@property NSArray *place;
@end @implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delimeters = @[[NSNull null], self.delim200, self.delim300, self.delim400, ];

    self.captionFormatter = [NSDateFormatter new];
    self.captionFormatter.dateFormat = @"EE";

    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-y";
    self.formatter.timeZone = [NSTimeZone systemTimeZone];

    self.man = [[ForecastManager alloc] initWithDelegate:self];

    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 78);
    self.view.alpha = 0.5f;
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.lastUpdate || [self.lastUpdate timeIntervalSinceNow] < -60) {
        self.lastUpdate = [NSDate new];
        self.places = [PlacesDataSource new];
        
        if (self.places.places.count) {
            self.emptyLabel.frame = CGRectMake(0, 0, 0, 0);
            self.place = [self.places.places firstObject];
            
            self.progressView.progress = 0.f;
            self.progressView.hidden = NO;
            
            [self.man requestForecastFor:self.place];
        } else {
            self.emptyLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}

- (void) forecastManager:(ForecastManager *)manager didReceivedForecast:(Forecast *)cast for:(NSArray *)place {
    if ([place isEqual:self.place]) {
        [self populate:cast];
    }
}

- (void) forecastManager:(ForecastManager *)manager didMadeProgress:(NSUInteger)from to:(NSUInteger)to for:(NSArray *)place {
    if (place == self.place) {
        [self.progressView setProgress:(float) from/to animated:YES];
        self.progressView.hidden = from == to;
    }
}

- (void) populate:(Forecast *) cast {
    self.view.alpha = 1.f;
    
    NSDateFormatter *hourFormatter = [NSDateFormatter new];
    hourFormatter.dateFormat = @"H";

    NSDate *currentDate = [self.formatter dateFromString:[self.formatter stringFromDate:[NSDate new]]];
    DailyForecast *currentCast = [cast dailyForecastFor:currentDate];
    int hour = [hourFormatter stringFromDate:[NSDate new]].intValue;
    NSNumber *currentHour = [currentCast hourFor:hour];
    NSUInteger hourIdx = [currentCast.hours indexOfObject:currentHour];

    int offset = 100;
    for (int i = offset; i <= 400; i+= 100, hourIdx += 2) {
        BOOL changedDate = NO;
        if (hourIdx >= currentCast.hours.count) {
            currentDate = [currentDate dateByAddingTimeInterval:60*60*24];
            currentCast = [cast dailyForecastFor:currentDate];
            hourIdx = currentCast.hours.count / 3;
            changedDate = YES;
        }

        currentHour = currentCast.hours[hourIdx];
        HourlyForecast *cellCast = currentCast.hourlyForecast[currentHour];

        if (changedDate && i > offset) {
            NSUInteger key = i/100 - 1;
            if (self.delimeters.count > key)
                self.delimeters[key].constant = 20.f;
        }
        
        UILabel *l;

        l = [self.view viewWithTag:i + 1];
        l.font = [UIFont fontWithName:@"Weather Icons" size:15.f];
        l.text = [self tempTextFor:cellCast];

        l = [self.view viewWithTag:i + 2];
        l.text = [self windTextFor:cellCast.wind_speed direction:cellCast.wind_direction];

        l = [self.view viewWithTag:i + 3];
        if (i == offset) {
            l.text = NSLocalizedString(@"now", @"now widget string");
        } else {
            NSString *dayTitle = @"";
            if (changedDate) {
                dayTitle = [[self.captionFormatter stringFromDate:currentDate].uppercaseString substringToIndex:2];
                dayTitle = [dayTitle stringByAppendingString:@" "];
            }

            l.text = [NSString stringWithFormat:@"%@%02d:00", dayTitle, currentHour.intValue];
        }
    }
}

- (NSString *) tempTextFor:(HourlyForecast *) cast {
    SinoptikTime t = (cast.hour > 20 || cast.hour < 7) ? SinoptikTimeNight : SinoptikTimeDay;

    NSString *temperature = [NSString stringWithFormat:@"%d℃", cast.temperature];
    return [NSString stringWithFormat:@"%@ %@", [self weatherfontCharFor:t clouds:cast.clouds rain:cast.rain], temperature];
}

- (NSString *) weatherfontCharFor:(SinoptikTime) time clouds:(int) c rain:(int) r {
    if ([time isEqualToString:SinoptikTimeDay]) {
        switch (c)
        { case 0: switch (r) {
            case 0: return @"";
        } case 1: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 2: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 3: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 4: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 5: switch (r) {
            case 0: return @"";
        } case 6: switch (r) {
            case 0: return @"";
        } }
    } else {
        switch (c)
        { case 0: switch (r) {
            case 0: return @"";
        } case 1: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 2: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 3: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 4: switch (r) {
            case 0: return @"";
            case 1: return @"";
            case 2: return @"";
            case 3: return @"";
            case 4: return @"";
        } case 5: switch (r) {
            case 0: return @"";
        } case 6: switch (r) {
            case 0: return @"";
        } }
    }

    return nil;
}

- (NSString *) windTextFor:(float) val direction:(int) direction {
    NSArray *directions = @[@"↑", @"↗︎", @"→", @"↘︎", @"↓", @"↙︎", @"←", @"↖︎", @""];
    return [NSString stringWithFormat:@"%@%1.f%@", directions[direction], val, NSLocalizedString(@"m/s", @"meters per sec short")];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
