//
//  PlacesDataSource.h
//  
//
//  Created by shdwprince on 9/7/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlacesDataSource : NSObject <UITableViewDataSource>
@property (nonatomic) NSMutableArray *places;

+ (instancetype) instance;

- (void) moveEntryFrom:(NSUInteger) source to:(NSUInteger) target;
- (void) deleteEntryAt:(NSUInteger) idx;
- (void) addEntry:(NSArray *) entry;

@end
