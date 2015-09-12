//
//  ForecastManager.m
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import "ForecastManager.h"

@interface ForecastManager ()
@property NSMutableDictionary *forecastCache;
@property (weak) id<ForecastManagerDelegate> delegate;
@property NSOperationQueue *queue;
@end@implementation ForecastManager

- (instancetype) init {
    self = [super init];
    self.forecastCache = [NSMutableDictionary new];
    self.queue = [NSOperationQueue new];
    [self restore];
    return self;
}

- (instancetype) initWithDelegate:(id<ForecastManagerDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (void) requestForecastFor:(NSArray *)place {
    NSString *key = place[2];

    [self.queue cancelAllOperations];
    if (self.forecastCache[key]) {
        [self.delegate forecastManager:self didReceivedForecast:self.forecastCache[key] for:place];
    }

    [self.queue addOperationWithBlock:^{
        Forecast *forecats = [[SinoptikAPI api] forecastFor:key];
        if (!forecats) {
            return;
        }

        self.forecastCache[key] = forecats;
        [self store];

        if ([[NSOperationQueue currentQueue] isSuspended])
            return;

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate forecastManager:self didReceivedForecast:forecats for:place];
        });
    }];
}

#pragma mark - private methods

#pragma mark persistence

- (NSString *) databasePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);

    return [[documentDirectories firstObject] stringByAppendingPathComponent:@"forecast.data"];
}

- (void) store {
    //@TODO: cleanup foreastsCache
    [NSKeyedArchiver archiveRootObject:self.forecastCache toFile:[self databasePath]];
}

- (void) restore {
    @try {
        self.forecastCache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self databasePath]];
    } @catch (NSException *exception) {
        [[NSFileManager defaultManager] removeItemAtPath:[self databasePath] error:nil];
        @throw exception;
    }

    if (!self.forecastCache)
        self.forecastCache = [NSMutableDictionary new];
}

- (void) dealloc {
    [self.queue cancelAllOperations];
}

@end
