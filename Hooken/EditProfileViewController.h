//
//  EditProfileViewController.h
//  Hooken
//
//  Created by Dacodes on 30/12/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditProfileDelegate <NSObject>

-(void)reloadUser:(NSString*)name and:(NSString*)lastName;

@end

@interface EditProfileViewController : UIViewController

@property (strong, nonatomic) id <EditProfileDelegate> delegate;
@property (nonatomic,strong) NSString*firstName;
@property (nonatomic,strong) NSString*lastName;
@property (nonatomic,strong) NSString*email;

@end
