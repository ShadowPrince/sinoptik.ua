//
//  HourlyForecastTableViewCell.m
//  
//
//  Created by shdwprince on 9/9/15.
//
//

#define ROW_FONT_SIZE 14.f
#define HEADER_FONT_SIZE 11.f

#import "HourlyForecastTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface HourlyForecastTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *columnWidthContraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UIImageView *windDirectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *rainProbabilityLabel;
//---
@property UIView *separator;
@property AssetsManager *assets;
@end@implementation HourlyForecastTableViewCell

- (void)awakeFromNib {
    self.assets = [AssetsManager new];
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 0.f;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self justifyColumns];
    [super layoutSubviews];
}

- (void) setupSeparator {
    if (!self.separator) {
        UIView *separatorLineView = [[UIView alloc] init];
        separatorLineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:separatorLineView];

        NSMutableArray *new_constrants = [NSMutableArray new];
        NSDictionary *metrics = @{@"x": @32.f,
                                  @"b": @0.f,
                                  @"h": @1.f, };
        NSDictionary *dict = @{@"v": separatorLineView, };
        [new_constrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(x)-[v]|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:dict]];
        [new_constrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v(h)]-(b)-|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:dict]];

        [self addConstraints:new_constrants];
        self.separator = separatorLineView;
    }

    self.separator.backgroundColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0f];
}

- (void) populate:(HourlyForecast *) cast {
    CGFloat size = ROW_FONT_SIZE;
    self.temperatureLabel.font = [UIFont systemFontOfSize:size];
    self.humidityLabel.font = [UIFont systemFontOfSize:size];
    self.windLabel.font = [UIFont systemFontOfSize:size];
    self.rainProbabilityLabel.font = [UIFont systemFontOfSize:size];
    self.layer.borderWidth = 0.f;

    [self.assets cancelOperations];

    self.temperatureLabel.text = [NSString stringWithFormat:@"%d℃", cast.temperature];
    self.humidityLabel.text = [NSString stringWithFormat:@"%d%%", cast.humidity];
    self.windLabel.text = [NSString stringWithFormat:@"%.0f %@", cast.wind_speed, NSLocalizedString(@"m/s", "meters per second")];
    self.rainProbabilityLabel.text = [NSString stringWithFormat:@"%d%%", cast.rain_probability];

    self.timeLabel.text = [NSString stringWithFormat:@"%d:00", cast.hour];
    self.timeLabel.font = [UIFont systemFontOfSize:size];

    [self.assets loadMediumImageFor:cast callback:^(UIImage *image) {
        self.weatherImageView.image = image;
    }];


    if ([[self.assets sinoptikTimeFor:cast] isEqualToString:SinoptikTimeDay]) {
        self.timeLabel.backgroundColor = [UIColor colorWithRed:1.f green:0.9f blue:0.4f alpha:1.0f];
        self.timeLabel.textColor = [UIColor blackColor];
    } else {
        self.timeLabel.backgroundColor = [UIColor darkGrayColor];
        self.timeLabel.textColor = [UIColor whiteColor];
    }

    if (cast.wind_direction <= 7)
        self.windDirectionImageView.image = [AssetsManager windDirectionalImages][cast.wind_direction];
    else
        self.windDirectionImageView.image = nil;
}

- (void) setCurrent {
    self.separator.backgroundColor = [UIColor blackColor];
}

- (void) setHeader {
    CGFloat size = HEADER_FONT_SIZE;
    self.temperatureLabel.font = [UIFont systemFontOfSize:size];
    self.humidityLabel.font = [UIFont systemFontOfSize:size];
    self.windLabel.font = [UIFont systemFontOfSize:size];
    self.rainProbabilityLabel.font = [UIFont systemFontOfSize:size];
    self.timeLabel.backgroundColor = [UIColor whiteColor];

    self.temperatureLabel.text = NSLocalizedString(@"Temp.", @"temperature column");
    self.humidityLabel.text = NSLocalizedString(@"Humid.", @"humidity column");
    self.windLabel.text = NSLocalizedString(@"Wind", @"wind column");
    self.rainProbabilityLabel.text = NSLocalizedString(@"Rain%", @"rain probability column");
    self.timeLabel.text = @"";
    self.weatherImageView.image = nil;
    self.windDirectionImageView.image = nil;
}

#pragma mark helper

- (void) justifyColumns {
    CGFloat space = self.frame.size.width - 86.f - 82.f - 24.f;
    self.columnWidthContraint.constant = space / 3;
}

@end
