//
//  CreateAccountViewController.m
//  Hooken
//
//  Created by Dacodes on 04/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "AFNetworking.h"

@interface CreateAccountViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>{
    UIView *maskView;
    UIPickerView *pickerView;
    UIToolbar *toolBar;
    NSInteger indexSelected;
    NSString *rolSelected;
    NSArray*rolOptions;
    NSArray *rolSelectedKey;
    NSArray*rolOptionsKeys;
}

@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *rolButton;

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.user.tag=1;
    self.user.delegate=self;
    self.password.tag=2;
    self.password.delegate=self;
    self.email.tag=3;
    self.email.delegate=self;
    
    [self.rolButton addTarget:self action:@selector(createPickerView) forControlEvents:UIControlEventTouchUpInside];
    
    indexSelected=0;
    
    rolOptions=@[@"Conductor",@"Pasajero",@"Conductor y Pasajero"];
    rolOptionsKeys=@[@[@"ROLE_RIDER"],@[@"ROLE_PASAJERO"],@[@"ROLE_RIDER",@"ROLE_PASAJERO"]];
    rolSelected=rolOptions[0];
    rolSelectedKey=rolOptionsKeys[0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPickerView{
    [self.rolButton setTitle:rolSelected forState:UIControlStateNormal];
    [self.view endEditing:YES];
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [maskView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    [self.view addSubview:maskView];
    
    pickerView=[[UIPickerView alloc] init];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.translatesAutoresizingMaskIntoConstraints=NO;
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickerView selectRow:indexSelected inComponent:0 animated:YES];
    [maskView addSubview:pickerView];
    [maskView addConstraint:[NSLayoutConstraint constraintWithItem:pickerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:maskView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    toolBar = [[UIToolbar alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints=NO;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissActionSheet:)];
    [done setTintColor:[UIColor whiteColor]];
    toolBar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    [maskView addSubview:toolBar];
    [maskView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar]-[picker]|" options:0 metrics:nil views:@{@"toolBar":toolBar,@"picker":pickerView}]];
    [maskView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolBar]|" options:0 metrics:nil views:@{@"toolBar":toolBar,@"picker":pickerView}]];
}


- (void)dismissActionSheet:(id)sender{
    [self.rolButton setTitle:rolSelected forState:UIControlStateNormal];

    [maskView removeFromSuperview];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark - PickerView Delegate-DataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [rolOptions count];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    rolSelected = rolOptions[row];
    rolSelectedKey = rolOptionsKeys[row];
    indexSelected=row;
    [self.rolButton setTitle:rolSelected forState:UIControlStateNormal];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.textColor=[UIColor blackColor];
    }
    // Fill the label text here
    tView.text=rolOptions[row];
    return tView;
}

#pragma mark - Register Account

-(IBAction)registerAccount{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*parameters=@{@"activated": [NSNumber numberWithBool:true],
                              @"authorities": rolSelectedKey,
                              @"email":self.email.text,
                              @"firstName":@"",
                              @"langKey":@"es",
                              @"lastName":@"",
                              @"login":self.user.text,
                              @"password":self.password.text
                              };
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:@"http://69.46.5.165:8084/rider/api/register" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        //[self setUserAuthentication:YES];
        //[self performSegueWithIdentifier:@"Start" sender:self];
        NSInteger statusCode = operation.response.statusCode;
        NSLog(@"Response: %li", (long)statusCode);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
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
