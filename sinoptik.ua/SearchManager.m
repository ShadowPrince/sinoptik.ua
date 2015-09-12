//
//  SearchManager.m
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import "SearchManager.h"

@interface SearchManager ()
@property NSOperationQueue *queue;
@end@implementation SearchManager

- (instancetype) init {
    self = [super init];
    self.queue = [NSOperationQueue new];
    return self;
}

- (void) search:(NSString *)query callback:(SearchManagerCallback)cb {
    [self.queue cancelAllOperations];

    [self.queue addOperationWithBlock:^{
        NSArray *data = [[SinoptikAPI api] searchPlaces:query];

        dispatch_async(dispatch_get_main_queue(), ^{
            cb(data);
        });
    }];
}

- (void) dealloc {
    [self.queue cancelAllOperations];
}

@end
