//
//  AssetsManager.m
//  
//
//  Created by shdwprince on 9/9/15.
//
//

#import "AssetsManager.h"

@interface AssetsManager ()
@property NSOperationQueue *queue;
@end@implementation AssetsManager

- (instancetype) init {
    self = [super init];
    self.queue = [NSOperationQueue new];
    //@TODO: day/night images, refactor
    return self;
}

- (void) loadImageFor:(HourlyForecast *)cast callback:(AssetsManagerLoadImageCallback)callback {
    [self.queue addOperationWithBlock:^{
        NSData *data = [[SinoptikAPI api] imageForForecast:cast
                                                    ofSize:SinoptikImageSizeBig
                                                      time:[self sinoptikTimeFor:cast]];
        UIImage *image = [UIImage imageWithData:data];

        if ([NSOperationQueue currentQueue].isSuspended)
            return;

        dispatch_sync(dispatch_get_main_queue(), ^{
            callback(image);
        });
    }];
}

- (void) loadMediumImageFor:(HourlyForecast *) cast callback:(AssetsManagerLoadImageCallback) callback {
    [self.queue addOperationWithBlock:^{
        NSData *data = [[SinoptikAPI api] imageForForecast:cast
                                                    ofSize:SinoptikImageSizeMedium
                                                      time:[self sinoptikTimeFor:cast]];
        UIImage *image = [UIImage imageWithData:data];

        if ([NSOperationQueue currentQueue].isSuspended)
            return;

        dispatch_sync(dispatch_get_main_queue(), ^{
            callback(image);
        });
    }];
}

+ (NSArray *) windDirectionalImages {
    static NSMutableArray *images = nil;
    if (!images) {
        UIImage *image = [UIImage imageNamed:@"south"];
        images = [NSMutableArray new];

        for (int i = 0; i < HourlyForecast.wind_directions.count - 1; i++) {
            images[i] = [image imageRotatedByDegrees:45.f * i + 180.f];
        };
    }

    return images;
}

- (void) cancelOperations {
    [self.queue cancelAllOperations];
}

- (SinoptikTime) sinoptikTimeFor:(HourlyForecast *) cast {
    return (cast.hour > 10 && cast.hour < 7) ? SinoptikTimeNight : SinoptikTimeDay;
}

- (void) dealloc {
    [self.queue cancelAllOperations];
}

@end
