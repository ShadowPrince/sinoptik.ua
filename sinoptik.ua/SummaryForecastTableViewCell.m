//
//  SummaryForecastTableViewCell.m
//  
//
//  Created by shdwprince on 9/13/15.
//
//

#import "SummaryForecastTableViewCell.h"

@interface SummaryForecastTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
//---
@property NSDateFormatter *formatter;
@end@implementation SummaryForecastTableViewCell

- (void)awakeFromNib {
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-yy";
}

- (void) populate:(DailyForecast *)cast {
    self.dateLabel.text = [NSString stringWithFormat:@"Последнее обновление: %@", [self.formatter stringFromDate:cast.last_update]];
}

@end
