//
//  ForecastViewController.h
//  sinoptik.ua
//
//  Created by shdwprince on 2/18/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForecastManager.h"
#import "PlacesDataSource.h"
#import "AssetsManager.h"
#import "GraphController.h"

#import "SHLineGraphView.h"
#import "SHPlot.h"

@interface ForecastViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ForecastManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@end
