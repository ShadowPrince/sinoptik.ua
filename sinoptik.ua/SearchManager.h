//
//  SearchManager.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <Foundation/Foundation.h>
#import "SinoptikAPI.h"

typedef void (^SearchManagerCallback)(NSArray *);

@interface SearchManager : NSObject

- (void) search:(NSString *) query
       callback:(SearchManagerCallback) cb;

@end
