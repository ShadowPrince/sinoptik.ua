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
    return self;
}

- (void) loadImageFor:(HourlyForecast *)cast callback:(AssetsManagerLoadImageCallback)callback {
    [self loadImageOfSize:SinoptikImageSizeBig for:cast callback:callback];
}

- (void) loadMediumImageFor:(HourlyForecast *) cast callback:(AssetsManagerLoadImageCallback) callback {
    [self loadImageOfSize:SinoptikImageSizeMedium for:cast callback:callback];
}

- (void) loadBigImageFor:(HourlyForecast *) cast callback:(AssetsManagerLoadImageCallback) callback {
    NSString *name = [[SinoptikAPI api] imageNameFor:cast ofSize:SinoptikImageSizeBig time:[self sinoptikTimeFor:cast]];
    UIImage *image = [UIImage imageNamed:name];
    callback(image);
}

- (void) loadImageOfSize:(SinoptikImageSize) size for:(HourlyForecast *) cast callback:(AssetsManagerLoadImageCallback) cb {
    [self.queue addOperationWithBlock:^{
        NSData *data = [[SinoptikAPI api] imageForForecast:cast
                                                    ofSize:size
                                                      time:[self sinoptikTimeFor:cast]];
        UIImage *image = [UIImage imageWithData:data];

        if ([NSOperationQueue currentQueue].isSuspended)
            return;

        if ([size isEqualToString:SinoptikImageSizeBig]) {
            image = [image imageAtRect:CGRectMake(42.f,
                                                  20.f,
                                                  image.size.width - 42.f * 2,
                                                  image.size.height - 20.f * 2)];
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            cb(image);
        });
    }];
}

- (UIImage *) fancyImageFor:(HourlyForecast *) cast {
    SinoptikTime time = [self sinoptikTimeFor:cast];
    NSString *key;

    if ([time isEqualToString:SinoptikTimeDay]) {
        if (cast.clouds && cast.rain ) {
            key = @"day-rain";
        } else if (cast.clouds) {
            switch (cast.clouds) {
                case 4:
                    key = @"day-clouds4";
                    break;

                case 3:
                    key = @"day-clouds3";
                case 2:
                    key = @"day-clouds2";
                case 1:
                default:
                    key = @"day-clouds1";
                    break;
            }
        } else if (cast.rain) {
            key = @"day-sunrain";
        } else {
            key = @"day-sun";
        }

        if (cast.frost > 1) {
            key = @"day-snow";
        }
    } else {
        if (cast.clouds && cast.rain) {
            key = @"night-rain";
        } else if (cast.clouds) {
            key = @"night-clouds";
        } else if (cast.rain) {
            key = @"night-rain";
        } else {
            key = @"night-clear";
        }

        if (cast.frost > 1) {
            key = @"night-snow";
        }
    }

    return [UIImage imageNamed:key];
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
    return (cast.hour >= 20 || cast.hour <= 5) ? SinoptikTimeNight : SinoptikTimeDay;
}

- (void) dealloc {
    [self.queue cancelAllOperations];
}

@end
