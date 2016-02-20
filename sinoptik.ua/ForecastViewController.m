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
@property (weak, nonatomic) IBOutlet UITableView *popupTableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgress;

@property PlacesDataSource *places;
@property ForecastManager *man;
@property AssetsManager *assets;
@property NSDateFormatter *formatter;

@property NSArray *place;
@property Forecast *cast;
@property BOOL initialLoading;
@end @implementation ForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-yyyy";
    self.man = [[ForecastManager alloc] initWithDelegate:self];

    self.assets = [[AssetsManager alloc] init];
    self.places = [[PlacesDataSource alloc] init];
    self.places.places = [NSMutableArray new];
    if (self.places.places.count == 0) {
        [self.places addEntry:@[@"Чернигов", @"0", @"погода-чернигов"]];
        [self.places addEntry:@[@"Шаповаловка", @"0", @"погода-шаповаловка"]];
        [self.places addEntry:@[@"Киев", @"0", @"погода-киев"]];
    }

    self.initialLoading = YES;
    self.place = self.places.places.firstObject;

    self.popupTableView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.initialLoading) {
        [self reload];
        self.initialLoading = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reload {
    [self showLoadingView];
    [self.popupTableView reloadData];
    [self.man requestForecastFor:self.place];
}

- (void) showLoadingView {
    self.loadingProgress.progress = 0.f;
    self.loadingView.alpha = 0.f;
    self.loadingView.hidden = NO;
    self.loadingView.frame = self.view.frame;
    [UIView animateWithDuration:0.3f delay:0.3f options:0 animations:^{
        self.loadingView.alpha = 1.f;
    } completion:^(BOOL finished) {}];
}

- (void) removeLoadingView {
    self.loadingView.hidden = YES;
}

#pragma mark - change city
- (IBAction)changeCityAction:(UIButton *)sender {
    CGPoint point = [self.view convertPoint:sender.frame.origin fromView:sender.superview];
    self.popupTableView.frame = CGRectMake(0, point.y, 0, 0);
    self.popupTableView.hidden = NO;
    self.popupTableView.alpha = 0.f;

    [self viewDidLayoutSubviews];

    [UIView animateWithDuration:0.3f animations:^{
        self.popupTableView.alpha = 1.f;
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.places.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSMutableArray *places = self.places.places;
    while (places.firstObject != self.place) {
        NSObject *place = places.firstObject;
        [places removeObjectAtIndex:0];
        [places addObject:place];
    }
    
    NSArray *entry = places[indexPath.row];
    [(UILabel *) [cell viewWithTag:100] setText:[entry firstObject]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *places = self.places.places;
    while (places.firstObject != self.place) {
        NSObject *place = places.firstObject;
        [places removeObjectAtIndex:0];
        [places addObject:place];
    }
    
    NSArray *entry = places[indexPath.row];
    self.place = entry;
    [self reload];

    [UIView animateWithDuration:0.3f animations:^{
        tableView.alpha = 0.f;
    } completion:^(BOOL finished) {
        tableView.hidden = YES;
    }];
}

#pragma mark - daily forecast
- (void) forecastManager:(ForecastManager *)manager didReceivedForecast:(Forecast *)cast for:(NSArray *)place {
    if (place == self.place) {
        self.cast = cast;
        [self.collectionView reloadData];
        [self removeLoadingView];
    }
}

- (void) forecastManager:(ForecastManager *)manager didMadeProgress:(NSUInteger)from to:(NSUInteger)to for:(NSArray *)place {
    if (place == self.place) {
        [self.loadingProgress setProgress:(float) from/to animated:YES];
    }
}

- (void) viewDidLayoutSubviews {
    [self.collectionView reloadData];

    float width = 150.f;
    self.popupTableView.frame = CGRectMake(self.view.frame.size.width - width - 5.f, self.popupTableView.frame.origin.y, width, 300.f);

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
    UIButton *currentCity = [cell viewWithTag:103];

    NSDate *date = [self.cast.dates objectAtIndex:indexPath.row];
    DailyForecast *forecast = [self.cast dailyForecastFor:date];
    HourlyForecast *middayForecast = [forecast middayForecast];

    currentDate.text = [self.formatter stringFromDate:date];
    [currentCity setTitle:self.place.firstObject forState:UIControlStateNormal];
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
