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
    self.windLabel.text = [NSString stringWithFormat:@"%.0f m/s", cast.wind_speed];
    self.rainProbabilityLabel.text = [NSString stringWithFormat:@"%d%%", cast.rain_probability];

    self.timeLabel.text = [NSString stringWithFormat:@"%d:00", cast.hour];
    self.timeLabel.font = [UIFont systemFontOfSize:size];

    [self.assets loadMediumImageFor:cast callback:^(UIImage *image) {
        self.weatherImageView.image = image;
    }];

    if (cast.hour > 8 && cast.hour < 22) {
        self.timeLabel.backgroundColor = [UIColor yellowColor];
        self.timeLabel.textColor = [UIColor blackColor];
    } else {
        self.timeLabel.backgroundColor = [UIColor darkGrayColor];
        self.timeLabel.textColor = [UIColor whiteColor];
    }

    if (cast.wind_direction < 8)
        self.windDirectionImageView.image = [AssetsManager windDirectionalImages][cast.wind_direction];
}

- (void) setCurrent {
    self.layer.borderWidth = 1.f;
}

- (void) setHeader {
    CGFloat size = HEADER_FONT_SIZE;
    self.temperatureLabel.font = [UIFont systemFontOfSize:size];
    self.humidityLabel.font = [UIFont systemFontOfSize:size];
    self.windLabel.font = [UIFont systemFontOfSize:size];
    self.rainProbabilityLabel.font = [UIFont systemFontOfSize:size];
    self.timeLabel.backgroundColor = [UIColor whiteColor];

    self.temperatureLabel.text = @"Темп.";
    self.humidityLabel.text = @"Влажн.";
    self.windLabel.text = @"Ветер";
    self.rainProbabilityLabel.text = @"Осад%";
    self.timeLabel.text = @"";
    self.weatherImageView.image = nil;
    self.windDirectionImageView.image = nil;
}

#pragma mark helper

- (void) justifyColumns {
    CGFloat space = self.frame.size.width - 86.f - 82.f - 16.f;
    self.columnWidthContraint.constant = space / 3;
}

@end
