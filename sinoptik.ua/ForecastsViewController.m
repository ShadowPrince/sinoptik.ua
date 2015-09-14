//
//  ForecastsViewController.m
//  
//
//  Created by shdwprince on 9/9/15.
//
//

#import "ForecastsViewController.h"

@interface ForecastsViewController ()
@property PlacesDataSource *places;
@property ForecastManager *forecastManager;
@property BOOL viewChangedSize;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property UIView *forecastsView;
@property NSMutableDictionary *forecastViewControllers;
@property NSMutableDictionary *forecastVCConstraints;
@end

@implementation ForecastsViewController

- (IBAction)showPlaces:(id)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self performSegueWithIdentifier:@"modallyShowPlacesSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showPlacesSegue" sender:self];
    }
}

- (IBAction)unwindFromPlaces:(UIStoryboardSegue *)sender {
    self.key = [(PlacesViewController *) sender.sourceViewController selected_index];

    for (UIView *view in self.contentView.subviews)
        [view removeFromSuperview];

    self.forecastViewControllers = [NSMutableDictionary new];
    self.contentViewWidthConstraint.constant = 0;
    self.scrollView.contentOffset = CGPointZero;
    self.loadingView.hidden = NO;

    [self loadForecastForKey];
    [self layoutControllers];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutControllers];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.places = [PlacesDataSource instance];
    self.forecastVCConstraints = [NSMutableDictionary new];
    self.forecastViewControllers = [NSMutableDictionary new];
    self.forecastManager = [[ForecastManager alloc] initWithDelegate:self];

    if (self.places.places.count)
        self.key = 0;
    else
        self.key = -1;

    [self loadForecastForKey];
}

- (void) viewDidAppear:(BOOL)animated {
    [self layoutControllers];

    if (!self.places.places.count)
        [self showPlaces:nil];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.scrollView.contentOffset = CGPointZero;
}

- (void) forecastManager:(ForecastManager *)manager didReceivedForecast:(Forecast *)cast for:(NSArray *)place {
    NSDate *today = [NSDate date];
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"yyyy-MM-dd";
    today = [f dateFromString:[f stringFromDate:today]];

    [cast.dailyForecasts enumerateKeysAndObjectsUsingBlock:^(NSDate *key, DailyForecast *obj, BOOL *stop)  {
        if ([key timeIntervalSinceDate:today] < 0)
            return;

        ForecastViewController *controller = nil;
        if (!self.forecastViewControllers[key]) {
            controller = [[ForecastViewController alloc] initWithPlace:place date:key];
            controller.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:controller.view];
            self.forecastViewControllers[key] = controller;
        } else {
            controller = self.forecastViewControllers[key];
        }

        [controller populate:obj];
    }];

    [self updateTitle];
    self.loadingView.hidden = YES;
}

#pragma mark helper

- (void) layoutControllers {
    NSArray *orderedKeys = [self.forecastViewControllers.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];

    CGFloat width = self.scrollView.frame.size.width;
    self.contentViewWidthConstraint.constant = width * orderedKeys.count;
    CGFloat height = self.contentView.frame.size.height;

    int i = 0;
    for (NSDate *key in orderedKeys) {
        ForecastViewController *controller = self.forecastViewControllers[key];
        [self.contentView removeConstraints:self.forecastVCConstraints[key]];

        NSDictionary *dict = @{@"c": self.contentView, @"v": controller.view};
        NSDictionary *metrics = @{@"x": [NSNumber numberWithInt:width * i],
                                  @"y": @0,
                                  @"w": [NSNumber numberWithDouble:width],
                                  @"h": [NSNumber numberWithDouble:height], };

        NSMutableArray *new_constrants = [NSMutableArray new];
        [new_constrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(x)-[v(w)]"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:dict]];
        [new_constrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(y)-[v(h)]"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:dict]];
        self.forecastVCConstraints[key] = new_constrants;
        [self.contentView addConstraints:new_constrants];
        i++;
    }
}

- (void) updateTitle {
    int idx = ceilf((float) self.scrollView.contentOffset.x / self.view.frame.size.width);
    NSArray *orderedKeys = [self.forecastViewControllers.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];

    if (orderedKeys.count > idx) {
        NSString *date = [(ForecastViewController *) self.forecastViewControllers[orderedKeys[idx]] title];
        self.title = date;
    }
}

- (void) loadForecastForKey {
    if (self.key != -1) {
        [self.forecastManager requestForecastFor:self.places.places[self.key]];
    }
}

#pragma mark - scroll view

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateTitle];
}


@end
