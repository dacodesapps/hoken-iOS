//
//  TabBarViewController.m
//  Hooken
//
//  Created by Dacodes on 17/10/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()<UITabBarControllerDelegate>

@property (nonatomic,strong) UILabel* cameraLabel;
@property (nonatomic,strong) UIButton* button;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate=self;
    self.tabBar.translucent= NO;
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
//    [tabBarItem1 setSelectedImage:[UIImage imageNamed:@"Tab1Selected"]];
//    UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
//    [tabBarItem2 setSelectedImage:[UIImage imageNamed:@"Tab2Selected"]];
//    UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
//    [tabBarItem4 setSelectedImage:[UIImage imageNamed:@"Tab4Selected"]];
//    UITabBarItem *tabBarItem5 = [self.tabBar.items objectAtIndex:4];
//    [tabBarItem5 setSelectedImage:[UIImage imageNamed:@"Tab5Selected"]];
    self.tabBar.tag=2;
    //[[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [self addCenterButtonWithImage:[UIImage imageNamed:@"Tab2"] highlightImage:[UIImage imageNamed:@"Tab2Selected"]];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessages" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    self.cameraLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 20)];
    self.cameraLabel.text=@"SELL IT!";
    self.cameraLabel.center=CGPointMake(self.tabBar.center.x, self.tabBar.center.y+19);
    self.cameraLabel.textColor=[UIColor whiteColor];
    self.cameraLabel.textAlignment=NSTextAlignmentCenter;
    self.cameraLabel.font=[UIFont fontWithName:@"Gotham-Book" size:9.0f];
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    self.button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    self.button.tag=1;
    [self.button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0){
        self.button.center = self.tabBar.center;
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        self.button.center = center;
    }
    
    self.button.layer.masksToBounds = NO;
    self.button.layer.shadowOffset = CGSizeMake(0,0);
    self.button.layer.shadowRadius = 3;
    self.button.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:self.button];
    //[self.view addSubview:self.cameraLabel];
}

-(void)showMap{
    [self setSelectedIndex:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
