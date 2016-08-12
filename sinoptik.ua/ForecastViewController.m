//
//  ForecastViewController.m
//  sinoptik.ua
//
//  Created by shdwprince on 2/18/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#import "ForecastViewController.h"

@interface ForecastViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temperatureGraphHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windGraphHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yearbeforeHeightConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *changeCityButton;
@property (weak, nonatomic) IBOutlet UITableView *popupTableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgress;
@property (weak, nonatomic) IBOutlet UIView *pagerContainer;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;

@property (weak, nonatomic) IBOutlet UIView *temperatureGraphContainer;
@property (weak, nonatomic) IBOutlet UIView *windGraphContainer;

@property DIBPagination *pager;
@property NSUInteger pagerPage;

@property GraphController *graphController;
@property PlacesDataSource *places;
@property ForecastManager *man;
@property AssetsManager *assets;
@property NSDateFormatter *formatter, *cellDateFormatter;

@property NSArray *temperatureGraphData, *windGraphData;
@property NSArray *place;
@property Forecast *cast;
@property NSUInteger castOffset;
@property BOOL initialLoading;

@end @implementation ForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-y";

    self.cellDateFormatter = [NSDateFormatter new];
    self.cellDateFormatter.dateFormat = @"cccc, dd MMM";

    self.man = [[ForecastManager alloc] initWithDelegate:self];
    self.assets = [[AssetsManager alloc] init];
    self.places = [PlacesDataSource instance];
    self.graphController = [GraphController new];

    self.initialLoading = YES;
    self.popupTableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.loadingView.translatesAutoresizingMaskIntoConstraints = YES;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.collectionViewHeightConstraint.constant *= 2;
        self.temperatureGraphHeightConstraint.constant *= 1;
        self.windGraphHeightConstraint.constant *= 1;
        self.yearbeforeHeightConstraint.constant *= 1.5;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;


    if (self.initialLoading) {
        [self showLoadingView];
    }

    if (self.places.places.count == 0) {
        [self performSegueWithIdentifier:@"2settings" sender:self];
        self.initialLoading = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.initialLoading) {
        if (self.places.places.count) {
            self.place = self.places.places.firstObject;
        } else {
            return;
        }

        [self reload];
        self.initialLoading = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    CGFloat margin = 8.f;
    /*
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        margin = 8.f;
    }
    */

    self.collectionViewWidthConstraint.constant = self.view.frame.size.width - margin;
    [self.view layoutIfNeeded];

    [self.collectionView reloadData];
    
    [self.pagerContainer.subviews.firstObject removeFromSuperview];
    int paginationMax = [self collectionView:self.collectionView numberOfItemsInSection:0];
    self.pager = [[DIBPagination alloc] initWithFrame:self.pagerContainer.bounds
                                           parentView:self.pagerContainer
                                        paginationMax:paginationMax
                                            andColors:@[[UIColor blackColor], [UIColor blackColor]]];
    if (paginationMax) {
        [self.pager animateIn];
        [self.pager setPageIndexToIndex:self.pagerPage];
    }

    UIColor *labelColor = [UIColor colorWithRed:.5f green:.5f blue:.5f alpha:1.f];
    [self renderGraph:self.temperatureGraphData
                 into:self.temperatureGraphContainer
                theme:@{// plot
                        kPlotStrokeWidthKey : @1,
                        kWarmLineColor: [UIColor redColor],
                        kColdLineColor: [UIColor blueColor],
                        // graph
                        kXAxisLabelColorKey : labelColor,
                        kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                        kYAxisLabelColorKey : labelColor,
                        kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                        kZeroLineColor: [UIColor grayColor],
                        kHighlightLineColor: [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0],
                        kXAxisLabelHighlightColorKey: [UIColor blackColor],
                        kDotSizeKey: @3,
                        kPlotBackgroundLineColorKey : [UIColor colorWithRed:.9f green:.9f blue:.9f alpha:1.f], }];

    [self renderGraph:self.windGraphData
                 into:self.windGraphContainer
                theme:@{// plot
                        kPlotStrokeWidthKey : @2,
                        kWarmLineColor: [UIColor colorWithRed:0.5f green:0.9f blue:1.f alpha:1.f],
                        kColdLineColor: [UIColor clearColor],
                        // graph
                        kXAxisLabelColorKey : labelColor,
                        kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                        kYAxisLabelColorKey : labelColor,
                        kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10],
                        kZeroLineColor: [UIColor grayColor],
                        kHighlightLineColor: [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0],
                        kXAxisLabelHighlightColorKey: [UIColor blackColor],
                        kDotSizeKey: @3,
                        kPlotBackgroundLineColorKey : [UIColor colorWithRed:.9f green:.9f blue:.9f alpha:1.f], }];

    float width = 150.f;
    self.popupTableView.frame = CGRectMake(self.view.frame.size.width - width - 5.f, self.popupTableView.frame.origin.y, width, 300.f);

    [super viewDidLayoutSubviews];
}

- (void) reload {
    [self showLoadingView];
    [self.popupTableView reloadData];
    [self.man requestForecastFor:self.place];
    [self.view viewWithTag:2100].alpha = 0.5f;
    self.title = self.place.firstObject;

    [[NSOperationQueue new] addOperationWithBlock:^{
        NSTimeInterval yearInterval = [[self.formatter dateFromString:@"01-01-2016"]
                                       timeIntervalSinceDate:[self.formatter dateFromString:@"01-01-2015"]];
        NSDate *yearAgo = [[NSDate new] dateByAddingTimeInterval:-yearInterval];
        DailyForecast *dailyCast = [[SinoptikAPI api] forecastFor:self.place.lastObject at:yearAgo];
        if (!dailyCast)
            return;

        HourlyForecast *middayCast = dailyCast.middayForecast;
        NSArray *values = @[//[self.formatter stringFromDate:yearAgo],
                            [self tempTextFor:middayCast.temperature],
                            [self humTextFor:middayCast.humidity],
                            [self windTextFor:middayCast.wind_speed direction:middayCast.wind_direction], ];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            for (int i = 0; i < values.count; i++) {
                [(UILabel *) [self.view viewWithTag:2001 + i] setText:values[i]];
            }
            
            [(UIImageView *) [self.view viewWithTag:2000] setImage:[self.assets fancyImageFor:middayCast]];
            [self.view viewWithTag:2100].alpha = 1.f;
        }];
    }];
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

- (void) renderGraph:(NSArray *) data into:(UIView *) container theme:(NSDictionary *) theme {
    [[container subviews].firstObject removeFromSuperview];

    SHPlot *plot = [[SHPlot alloc] init];

    CGSize size = container.frame.size;
    SHLineGraphView *graph = [[SHLineGraphView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    graph.yAxisRange = data.firstObject;
    graph.yAxisSuffix = data[1];
    graph.xAxisValues = data[2];
    plot.plottingValues = data[3];
    graph.highlightColor = [UIColor blueColor];
    graph.highlightedXLabel = [(NSNumber *) data[4] integerValue];
    graph.zeroMode = [(NSNumber *) data[5] integerValue];

    NSArray *plotThemeKeys = @[kPlotStrokeWidthKey,
                               kWarmLineColor,
                               kColdLineColor, ];
    NSArray *graphThemeKeys = @[kXAxisLabelColorKey,
                           kXAxisLabelFontKey,
                           kYAxisLabelColorKey,
                           kYAxisLabelFontKey,
                           kZeroLineColor,
                           kHighlightLineColor,
                           kXAxisLabelHighlightColorKey,
                           kDotSizeKey,
                           kPlotBackgroundLineColorKey, ];

    NSMutableDictionary *graphTheme = [NSMutableDictionary new];
    NSMutableDictionary *plotTheme = [NSMutableDictionary new];

    for (NSString *key in plotThemeKeys) plotTheme[key] = theme[key];
    for (NSString *key in graphThemeKeys) graphTheme[key] = theme[key];

    graph.themeAttributes = graphTheme;
    plot.plotThemeAttributes = plotTheme;

    [graph addPlot:plot];
    [graph setupTheView];
    [container addSubview:graph];
}

- (void) forecastManager:(ForecastManager *)manager didReceivedForecast:(Forecast *)cast for:(NSArray *)place {
    if ([place isEqual:self.place]) {
        self.temperatureGraphData = [self.graphController temperatureGraphDataFor:cast];
        self.windGraphData = [self.graphController windGraphDataFor:cast];
        self.cast = cast;
        self.castOffset = manager.behindDays;

        NSDate *date = [self.formatter dateFromString:[self.formatter stringFromDate:[NSDate new]]];
        DailyForecast *dailyCast = [cast dailyForecastFor:date];
        NSArray *values = [dailyCast.daylight arrayByAddingObjectsFromArray:dailyCast.minMax];
        for (int i = 0; i < values.count; i++) {
            [(UILabel *) [self.view viewWithTag:1001 + i] setText:values[i]];
        }
        self.lastUpdateLabel.text = [self.formatter stringFromDate:dailyCast.last_update];

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
    return self.place == nil ? 0 : self.places.places.count;
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
    if (indexPath.row == 0) {
        [(UILabel *) [cell viewWithTag:100] setTextColor:self.view.tintColor];
    }

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
    UILabel *currentTime = [cell viewWithTag:104];
    UILabel *currentHum = [cell viewWithTag:105];
    UILabel *currentWind = [cell viewWithTag:106];

    NSDate *date = [self.cast.dates objectAtIndex:indexPath.row + self.castOffset];
    DailyForecast *forecast = [self.cast dailyForecastFor:date];
    HourlyForecast *middayForecast;
    if ([[self.formatter stringFromDate:[NSDate new]] isEqualToString:[self.formatter stringFromDate:date]]) {
        NSDateFormatter *hourFormatter = [NSDateFormatter new];
        hourFormatter.dateFormat = @"H";
        int hour = [hourFormatter stringFromDate:[NSDate new]].intValue;
        middayForecast = [forecast forecastFor:hour];
    } else {
        middayForecast = [forecast middayForecast];
    }

    currentHum.text = [self humTextFor:middayForecast.humidity];
    currentWind.text = [self windTextFor:middayForecast.wind_speed direction:middayForecast.wind_direction];
    //currentFeelslike.text = [self feelslikeTextFor:middayForecast.feelslikeTemperature];
    currentTime.text = [NSString stringWithFormat:@"%02d:00", middayForecast.hour];
    NSMutableString *strDate = [self.cellDateFormatter stringFromDate:date].mutableCopy;
    [strDate replaceCharactersInRange:NSMakeRange(0, 1) withString:[strDate substringToIndex:1].uppercaseString];
    currentDate.text = strDate;
    [currentCity setTitle:self.place.firstObject forState:UIControlStateNormal];
    currentTemp.text = [self tempTextFor:middayForecast.temperature];
    currentTemp.font = [UIFont fontWithName:@"Weather Icons" size:30.f];
    currentImageView.image = nil;
    [self.assets loadBigImageFor:middayForecast callback:^(UIImage *i) {
        currentImageView.image = i;
    }];

    NSArray<NSNumber *> *hours = @[@8, @14, @23];
    for (int i = 0; i < hours.count; i++) {
        NSNumber *hour = [forecast hourFor:hours[i].intValue];
        NSUInteger tag_prefix = i * 100 + 200;

        UIImageView *image = [cell viewWithTag:tag_prefix + 0];
        UILabel *temp = [cell viewWithTag:tag_prefix + 1];
        UILabel *hum = [cell viewWithTag:tag_prefix + 2];
        UILabel *wind = [cell viewWithTag:tag_prefix + 3];

        HourlyForecast *cast = [forecast hourlyForecast][hour];
        temp.text = [[self weatherfontCharFor:[self.assets sinoptikTimeFor:cast]
                                       clouds:cast.clouds
                                         rain:cast.rain]
                     stringByAppendingString:[self tempTextFor:cast.temperature]];
        temp.font = [UIFont fontWithName:@"Weather Icons" size:15.f];

        hum.text = [self humTextFor:cast.humidity];
        wind.text = [self windTextFor:cast.wind_speed direction:cast.wind_direction];
        image.image = [self.assets fancyImageFor:cast];
    }

    return cell;
}

- (NSString *) tempTextFor:(char) temp {
    return [NSString stringWithFormat:@"%d", temp];
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


- (NSString *) feelslikeTextFor:(char) temp {
    return [NSString stringWithFormat:@"%d~", temp];
}

- (NSString *) humTextFor:(int) val {
    return [NSString stringWithFormat:@"%d%%", val];
}

- (NSString *) windTextFor:(float) val direction:(int) direction {
    NSArray *directions = @[@"↑", @"↗︎", @"→", @"↘︎", @"↓", @"↙︎", @"←", @"↖︎", @""];
    return [NSString stringWithFormat:@"%@%1.f%@", directions[direction], val, NSLocalizedString(@"m/s", @"meterspersec")];
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger previousPage = self.pagerPage;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        [self.pager setPageIndexToIndex:page];
        self.pagerPage = page;
    }
}

@end
