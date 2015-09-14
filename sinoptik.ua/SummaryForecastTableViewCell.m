//
//  SummaryForecastTableViewCell.m
//  
//
//  Created by shdwprince on 9/13/15.
//
//

#import "SummaryForecastTableViewCell.h"

@interface SummaryForecastTableViewCell ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacingConstraint;
//---
@property NSDateFormatter *formatter;
@end@implementation SummaryForecastTableViewCell

- (void)awakeFromNib {
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-yy";
}

- (void) populate:(DailyForecast *)cast {
    if (![UIApplication sharedApplication].networkActivityIndicatorVisible) {
        [self.indicator stopAnimating];
        self.spacingConstraint.active = NO;
    }
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last update: %@", @"last update"), [self.formatter stringFromDate:cast.last_update]];
}

@end
