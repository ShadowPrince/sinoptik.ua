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
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *daylightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nowImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UIImageView *windDirectionImageView;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@end@implementation ForecastViewController

- (instancetype) initWithPlace:(NSArray *)place date:(NSDate *)d {
    self = [super init];
    self.date = d;
    self.place = place;
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"EEEE dd.MM.yy";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"HourlyForecastTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SummaryForecastTableViewCell" bundle:nil] forCellReuseIdentifier:@"Footer"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // remove text padding
    self.summaryTextView.textContainerInset = UIEdgeInsetsZero;
    self.summaryTextView.textContainer.lineFragmentPadding = 0.f;

    self.assets = [AssetsManager new];
}

- (void) populate:(DailyForecast *) cast {
    self.forecast = cast;
    self.summaryTextView.text = cast.summary;
    self.placeLabel.text = [self.place firstObject];

    HourlyForecast *currentCast;
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

        currentCast = self.forecast.hourlyForecast[self.current_hour];
    } else {
        int midday_hour = self.forecast.hourlyForecast.count / 2;
        // @TODO: something's wrong with big image
        currentCast = self.forecast.hourlyForecast.allValues[midday_hour];
    }

    [self.tableView reloadData];
    //@TODO: scroll
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row_index inSection:0]
//                          atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

    self.title = [self.formatter stringFromDate:self.date];
    self.dateLabel.text = [NSString stringWithFormat:@"%d℃", currentCast.temperature];
    self.windLabel.text = [NSString stringWithFormat:@"%.1fm/s", currentCast.wind_speed];
    self.daylightLabel.text = [NSString stringWithFormat:@"⇡%@ ⇣%@", cast.daylight[0], cast.daylight[1]];
    self.windDirectionImageView.image = [AssetsManager windDirectionalImages][currentCast.wind_direction];

    [self.assets loadImageFor:currentCast callback:^(UIImage *image) {
        self.nowImageView.image = image;
    }];
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

        if (indexPath.row == 0) { // header
            [cell setHeader];
        } else {
            NSNumber *key = [self.forecast hours][indexPath.row-1];
            HourlyForecast *cast = self.forecast.hourlyForecast[key];
            [cell populate:cast];
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
