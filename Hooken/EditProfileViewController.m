//
//  EditProfileViewController.m
//  Hooken
//
//  Created by Dacodes on 30/12/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AFNetworking.h"
#import "CustomTextField.h"
#import "Header.h"

@interface EditProfileViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *nameUser;
@property (weak, nonatomic) IBOutlet CustomTextField *lastNameUser;
@property (weak, nonatomic) IBOutlet CustomTextField *emailUser;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Editar Perfil";
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.nameUser.layer.cornerRadius = 6.0f;
    self.nameUser.layer.borderColor =[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0].CGColor;
    self.nameUser.layer.borderWidth = 0.6f;
    self.nameUser.layer.masksToBounds = YES;
    self.nameUser.delegate = self;
    self.nameUser.tag = 1;
    self.nameUser.offsetX = 40;
    self.nameUser.text = self.firstName;
    
    self.lastNameUser.layer.cornerRadius = 6.0f;
    self.lastNameUser.layer.borderColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0].CGColor;
    self.lastNameUser.layer.borderWidth = 0.6f;
    self.lastNameUser.layer.masksToBounds = YES;
    self.lastNameUser.delegate = self;
    self.lastNameUser.tag = 2;
    self.lastNameUser.offsetX = 40;
    self.lastNameUser.text = self.lastName;
    
    self.emailUser.layer.cornerRadius = 6.0f;
    self.emailUser.layer.borderColor =[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0].CGColor;
    self.emailUser.layer.borderWidth = 0.6f;
    self.emailUser.layer.masksToBounds = YES;
    self.emailUser.delegate = self;
    self.emailUser.tag = 1;
    self.emailUser.offsetX = 40;
    self.emailUser.text = self.email;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Edit Account

-(IBAction)editAccount{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*parameters=@{@"email":self.emailUser.text,
                              @"firstName":self.nameUser.text,
                              @"langKey":@"es",
                              @"lastName":self.lastNameUser.text
                              };
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    //[manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager POST:[NSString stringWithFormat:@"%@/rider/api/account",KAUTHURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        NSInteger statusCode = operation.response.statusCode;
        NSLog(@"Response: %li", (long)statusCode);
        NSLog(@"%@",(NSDictionary*)responseObject);
        [self.delegate reloadUser:self.nameUser.text and:self.lastNameUser.text];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", (NSDictionary*)operation.responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HokenToken"];
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
