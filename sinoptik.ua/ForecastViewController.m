//
//  ForecastViewController.m
//  sinoptik.ua
//
//  Created by shdwprince on 2/18/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#import "ForecastViewController.h"

@interface ForecastViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property ForecastManager *man;
@property AssetsManager *assets;
@property NSDateFormatter *formatter;

@property Forecast *cast;
@end @implementation ForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-yyyy";
    self.man = [[ForecastManager alloc] initWithDelegate:self];
    [self.man requestForecastFor:@[@0, @0, @"погода-чернигов"]];

    self.assets = [[AssetsManager alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) forecastManager:(ForecastManager *)manager didReceivedForecast:(Forecast *)cast for:(NSArray *)place {
    self.cast = cast;
    [self.collectionView reloadData];
}

- (void) viewDidLayoutSubviews {
    [self.collectionView reloadData];
    [super viewDidLayoutSubviews];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cast.dailyForecasts.count;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *currentImageView = [cell viewWithTag:100];
    UILabel *currentDate = [cell viewWithTag:101];
    UILabel *currentTemp = [cell viewWithTag:102];
    UILabel *currentCity = [cell viewWithTag:103];

    NSDate *date = [self.cast.dates objectAtIndex:indexPath.row];
    DailyForecast *forecast = [self.cast dailyForecastFor:date];
    HourlyForecast *middayForecast = [forecast middayForecast];

    currentDate.text = [self.formatter stringFromDate:date];
    currentCity.text = @"Чернигов";
    currentTemp.text = [self tempTextFor:middayForecast.temperature];
    currentImageView.image = nil;
    [self.assets loadBigImageFor:middayForecast callback:^(UIImage *i) {
        currentImageView.image = i;
        currentImageView.contentMode = UIViewContentModeScaleToFill;
    }];

    NSArray *hours = @[@8, @14, @2];
    for (int i = 0; i < hours.count; i++) {
        NSNumber *hour = hours[i];
        NSUInteger tag_prefix = i * 100 + 200;

        UIImageView *image = [cell viewWithTag:tag_prefix + 0];
        UILabel *temp = [cell viewWithTag:tag_prefix + 1];
        UILabel *hum = [cell viewWithTag:tag_prefix + 2];
        UILabel *wind = [cell viewWithTag:tag_prefix + 3];

        HourlyForecast *cast = [forecast hourlyForecast][hour];
        temp.text = [self tempTextFor:cast.temperature];
        hum.text = [self humTextFor:cast.humidity];
        wind.text = [self windTextFor:cast.wind_speed];
        image.image = [self.assets fancyImageFor:cast];
    }

    return cell;
}

- (NSString *) tempTextFor:(char) temp {
    return [NSString stringWithFormat:@"%d℃", temp];
}

- (NSString *) humTextFor:(int) val {
    return [NSString stringWithFormat:@"%d%%", val];
}

- (NSString *) windTextFor:(float) val {
    return [NSString stringWithFormat:@"%1.fms", val];
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

@end
