//
//  FirstViewController.h
//  Hooken
//
//  Created by Dacodes on 17/10/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController

@property (nonatomic,strong) NSString*firstName;
@property (nonatomic,strong) NSString*lastName;
@property (nonatomic,strong) NSString*email;
@property (nonatomic,strong) NSString*idUser;
@property (nonatomic,strong) NSString*role;
@property (nonatomic,assign) BOOL fromLoginOrRegister;

@end

