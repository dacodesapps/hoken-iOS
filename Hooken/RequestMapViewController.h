//
//  RequestMapViewController.h
//  Hooken
//
//  Created by Dacodes on 25/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestMapViewController : UIViewController

@property (nonatomic,strong) NSString*routeJson;
@property (nonatomic,strong) NSDictionary*routeDestination;
@property (nonatomic,strong) NSDictionary*routeStatus;
@property (nonatomic,strong) NSString*idRoute;
@property (nonatomic,strong) NSDictionary*riderInfo;

@end
