//
//  CheckRequestsViewController.h
//  Hooken
//
//  Created by Dacodes on 30/12/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckRequestsViewController : UIViewController

@property (nonatomic,strong) NSDictionary*userUbication;
@property (nonatomic,strong) NSString*routeJson;
@property (nonatomic,strong) NSString*idRoute;
@property (nonatomic,strong) NSArray*requests;
@property (nonatomic,assign) NSInteger row;

@end
