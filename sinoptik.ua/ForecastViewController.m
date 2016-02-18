//
//  ForecastViewController.m
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import "ForecastViewController.h"

@interface ForecastViewController ()
@property AssetsManager *assets;
@property DailyForecast *forecast;
@property NSDateFormatter *formatter;
@property NSNumber *current_hour;
@property NSDate *date;
@property NSArray *place;
//---
@property (weak, nonatomic) IBOutlet ILTranslucentView *headerAnchorView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *daylightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nowImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UIImageView *windDirectionImageView;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@end@implementation ForecastViewController

- (void) setPlace:(NSArray *) p date:(NSDate *) d {
    self.date = d;
    self.place = p;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"EEEE dd.MM.yy";

    [self.tableView registerNib:[UINib nibWithNibName:@"HourlyForecastTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SummaryForecastTableViewCell" bundle:nil] forCellReuseIdentifier:@"Footer"];

    self.nowImageView.layer.cornerRadius = self.nowImageView.frame.size.width / 2;
    self.nowImageView.layer.masksToBounds = YES;
    self.nowImageView.layer.borderWidth = 3.0f;
    self.nowImageView.layer.borderColor = [UIColor whiteColor].CGColor;

    // remove text padding
    if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
        self.summaryTextView.textContainerInset = UIEdgeInsetsZero;
        self.summaryTextView.textContainer.lineFragmentPadding = 0.f;
    }

    self.assets = [AssetsManager new];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat top = self.headerAnchorView.frame.origin.y + self.headerAnchorView.frame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
}

- (void) populate:(DailyForecast *) cast {
    self.forecast = cast;
    self.summaryTextView.text = cast.summary;
    self.placeLabel.text = [self.place firstObject];

    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"yyyy-MM-dd";
    int row_index = 0;

    if ([[f stringFromDate:self.date] isEqualToString:[f stringFromDate:[NSDate date]]]) {
        NSDate *date = [NSDate date];
        f.dateFormat = @"H";
        NSInteger current_hour = [f stringFromDate:date].integerValue;

        for (NSNumber *hour in [self.forecast hours]) {
            if (hour.integerValue > current_hour) {
                if (self.current_hour == nil)
                    self.current_hour = hour;
                break;
            } else {
                self.current_hour = hour;
                row_index ++;
            }
        }

        self.currentCast = self.forecast.hourlyForecast[self.current_hour];
    } else {
        self.currentCast = [self.forecast middayForecast];
    }

    [self.tableView reloadData];

    // header
    SinoptikTime currentTime = [self.assets sinoptikTimeFor:self.currentCast];
    [self changeHeaderColorsFor:currentTime];

    if ([UIDevice currentDevice].systemVersion.integerValue < 7) {
        CGFloat color = [currentTime isEqualToString:SinoptikTimeDay] ? 1.f : 0.f;
        self.headerAnchorView.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:0.9f];
    } else {
        self.headerAnchorView.translucentStyle = [currentTime isEqualToString:SinoptikTimeDay] ? UIBarStyleDefault : UIBarStyleBlackTranslucent;
    }

    self.title = [self.formatter stringFromDate:self.date];
    self.dateLabel.text = [NSString stringWithFormat:@"%d℃", self.currentCast.temperature];
    self.windLabel.text = [NSString stringWithFormat:@"%.1fm/s", self.currentCast.wind_speed];
    self.daylightLabel.text = [NSString stringWithFormat:@"⇡%@ ⇣%@", cast.daylight[0], cast.daylight[1]];
    if (self.currentCast.wind_direction <= 7)
        self.windDirectionImageView.image = [AssetsManager windDirectionalImages][self.currentCast.wind_direction];
    else
        self.windDirectionImageView.image = nil;

    [self.assets loadImageFor:self.currentCast callback:^(UIImage *image) {
        self.nowImageView.image = image;
    }];
}

#pragma mark - day/night colors

- (void) changeHeaderColorsFor:(SinoptikTime) time {
    UIColor *textColor = [time isEqualToString:SinoptikTimeNight] ? [UIColor whiteColor] : [UIColor darkTextColor];
    for (UIView *v in self.headerAnchorView.subviews) {
        if ([v respondsToSelector:@selector(setColor:)]) {
            [v performSelector:@selector(setColor:)
                    withObject:textColor];
        } else if ([v respondsToSelector:@selector(setTextColor:)]) {
            [v performSelector:@selector(setTextColor:)
                    withObject:textColor];
        }
    }
}

#pragma mark - table

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // header + footer
    return 1 + [self.forecast hours].count + 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.forecast.hours.count + 1) { // footer
        SummaryForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Footer"];
        [cell populate:self.forecast];
        return cell;
    } else {
        HourlyForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        [cell layoutIfNeeded];

        if (indexPath.row == 0) { // header
            [cell setHeader];
        } else {
            NSNumber *key = [self.forecast hours][indexPath.row-1];
            HourlyForecast *cast = self.forecast.hourlyForecast[key];
            [cell populate:cast];
            [cell setupSeparator];

            cell.backgroundColor = [UIColor whiteColor];

            if (self.current_hour && [key isEqualToNumber:self.current_hour])
                [cell setCurrent];
        }

        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == self.forecast.hours.count + 1) {
        return 30.f;
    } else {
        return 45.f;
    }
}

@end
