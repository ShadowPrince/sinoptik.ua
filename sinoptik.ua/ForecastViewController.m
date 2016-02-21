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
@property (weak, nonatomic) IBOutlet UIView *temperatureGraphContainer;

@property GraphController *graphController;
@property PlacesDataSource *places;
@property ForecastManager *man;
@property AssetsManager *assets;
@property NSDateFormatter *formatter;

@property NSArray *temperatureGraphData;
@property NSArray *place;
@property Forecast *cast;
@property NSUInteger castOffset;
@property BOOL initialLoading;

@end @implementation ForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-y";

    self.man = [[ForecastManager alloc] initWithDelegate:self];
    self.assets = [[AssetsManager alloc] init];
    self.places = [[PlacesDataSource alloc] init];
    self.graphController = [GraphController new];

    self.places.places = [NSMutableArray new];
    if (self.places.places.count == 0) {
        [self.places addEntry:@[@"Чернигов", @"0", @"погода-чернигов"]];
        [self.places addEntry:@[@"Шаповаловка", @"0", @"погода-шаповаловка"]];
        [self.places addEntry:@[@"Киев", @"0", @"погода-киев"]];
    }

    self.place = self.places.places.firstObject;

    self.initialLoading = YES;
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

- (void) viewDidLayoutSubviews {
    [self.collectionView reloadData];
    [self renderGraph:self.temperatureGraphData];

    float width = 150.f;
    self.popupTableView.frame = CGRectMake(self.view.frame.size.width - width - 5.f, self.popupTableView.frame.origin.y, width, 300.f);

    [super viewDidLayoutSubviews];
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

- (void) renderGraph:(NSArray *) data {
    [[self.temperatureGraphContainer subviews].firstObject removeFromSuperview];

    SHPlot *plot = [[SHPlot alloc] init];

    CGSize size = self.temperatureGraphContainer.frame.size;
    SHLineGraphView *graph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    graph.yAxisRange = data.firstObject;
    graph.yAxisSuffix = data[1];
    graph.xAxisValues = data[2];
    plot.plottingValues = data[3];
    graph.highlightColor = [UIColor blueColor];
    graph.highlightedXLabel = [(NSNumber *) data[4] integerValue];
    graph.zeroMode = [(NSNumber *) data[5] integerValue];

    NSDictionary *_plotThemeAttributes = @{kPlotStrokeWidthKey : @1,
                                           kWarmLineColor: [UIColor redColor],
                                           kColdLineColor: [UIColor blueColor], };

    plot.plotThemeAttributes = _plotThemeAttributes;

    UIColor *labelColor = [UIColor colorWithRed:.5f green:.5f blue:.5f alpha:1.f];
    NSDictionary *_themeAttributes = @{kXAxisLabelColorKey : labelColor,
                                       kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       kYAxisLabelColorKey : labelColor,
                                       kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                                       kZeroLineColor: [UIColor grayColor],
                                       kHighlightLineColor: [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0],
                                       kXAxisLabelHighlightColorKey: [UIColor blackColor],
                                       kDotSizeKey: @3,
                                       kPlotBackgroundLineColorKey : [UIColor colorWithRed:.9f green:.9f blue:.9f alpha:1.f], };
    graph.themeAttributes = _themeAttributes;

    [graph addPlot:plot];
    [graph setupTheView];
    [self.temperatureGraphContainer addSubview:graph];
}

- (void) forecastManager:(ForecastManager *)manager didReceivedForecast:(Forecast *)cast for:(NSArray *)place {
    if (place == self.place) {
        self.temperatureGraphData = [self.graphController graphDataFor:cast];
        self.cast = cast;
        self.castOffset = manager.behindDays;

        [self viewDidLayoutSubviews];
        [self removeLoadingView];
    }
}

- (void) forecastManager:(ForecastManager *)manager didMadeProgress:(NSUInteger)from to:(NSUInteger)to for:(NSArray *)place {
    if (place == self.place) {
        [self.loadingProgress setProgress:(float) from/to animated:YES];
    }
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

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cast.dailyForecasts.count - self.castOffset;
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
    UILabel *currentHum = [cell viewWithTag:104];
    UILabel *currentFeelslike = [cell viewWithTag:105];
    UILabel *currentWind = [cell viewWithTag:106];

    NSDate *date = [self.cast.dates objectAtIndex:indexPath.row + self.castOffset];
    DailyForecast *forecast = [self.cast dailyForecastFor:date];
    HourlyForecast *middayForecast;
    if ([[self.formatter stringFromDate:[NSDate new]] isEqualToString:[self.formatter stringFromDate:date]]) {
        NSDateFormatter *hourFormatter = [NSDateFormatter new];
        hourFormatter.dateFormat = @"H";
        int hour = [hourFormatter stringFromDate:[NSDate new]].integerValue;
        middayForecast = [forecast forecastFor:hour];
    } else {
        middayForecast = [forecast middayForecast];
    }

    currentHum.text = [self humTextFor:middayForecast.humidity];
    currentWind.text = [self windTextFor:middayForecast.wind_speed direction:middayForecast.wind_direction];
    currentFeelslike.text = [self feelslikeTextFor:middayForecast.feelslikeTemperature];
    currentDate.text = [self.formatter stringFromDate:date];
    [currentCity setTitle:self.place.firstObject forState:UIControlStateNormal];
    currentTemp.text = [self tempTextFor:middayForecast.temperature];
    currentImageView.image = nil;
    [self.assets loadBigImageFor:middayForecast callback:^(UIImage *i) {
        currentImageView.image = i;
    }];

    NSArray *hours = @[@8, @14, @2];
    for (int i = 0; i < hours.count; i++) {
        NSNumber *hour = hours[i];
        NSUInteger tag_prefix = i * 100 + 200;

        UIImageView *image = [cell viewWithTag:tag_prefix + 0];
        //UIImageView *sinoptikImage = [cell viewWithTag:tag_prefix + 4];
        UILabel *temp = [cell viewWithTag:tag_prefix + 1];
        UILabel *hum = [cell viewWithTag:tag_prefix + 2];
        UILabel *wind = [cell viewWithTag:tag_prefix + 3];

        HourlyForecast *cast = [forecast hourlyForecast][hour];
        temp.text = [self tempTextFor:cast.temperature];
        hum.text = [self humTextFor:cast.humidity];
        wind.text = [self windTextFor:cast.wind_speed direction:cast.wind_direction];
        image.image = [self.assets fancyImageFor:cast];
        /*
        [self.assets loadImageFor:cast callback:^(UIImage *i) {
            sinoptikImage.image = i;
        }];
         */
    }

    return cell;
}

- (NSString *) tempTextFor:(char) temp {
    return [NSString stringWithFormat:@"%d℃", temp];
}

- (NSString *) feelslikeTextFor:(char) temp {
    return [NSString stringWithFormat:@"%d℃~", temp];
}

- (NSString *) humTextFor:(int) val {
    return [NSString stringWithFormat:@"%d%%", val];
}

- (NSString *) windTextFor:(float) val direction:(int) direction {
    NSArray *directions = @[@"↑", @"↗︎", @"→", @"↘︎", @"↓", @"↙︎", @"←", @"↖︎", @""];
    return [NSString stringWithFormat:@"%@%1.fms", directions[direction], val];
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

@end
