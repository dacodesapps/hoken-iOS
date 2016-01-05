//
//  ThirdViewController.m
//  Hooken
//
//  Created by Dacodes on 11/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "ThirdViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "DestinationTableViewCell.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "CheckRequestsViewController.h"
#import "Header.h"

@interface ThirdViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray*requests;
}

@property (nonatomic,strong) IBOutlet UITableView* myTableView;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Solicitudes";
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor greenColor];
    [refreshControl addTarget:self action:@selector(getRides:) forControlEvents:UIControlEventValueChanged];
    UITableViewController *tableVC = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    [tableVC setTableView:self.myTableView];
    tableVC.refreshControl = refreshControl;
    
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    
    [self getRides:nil];
}

#pragma mark - Requests

-(void)getRides:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    UIRefreshControl*refreshControl = (UIRefreshControl *)sender;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.myTableView animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager GET:[NSString stringWithFormat:@"%@/rider/api/solicitudRiders",KAUTHURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [MBProgressHUD hideHUDForView:self.myTableView animated:YES];
        [refreshControl endRefreshing];
        requests=(NSArray*)responseObject;
        NSLog(@"JSON Routes: %@", requests);
        [self.myTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
        [refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.myTableView animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [requests count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier=@"Cell";
    DestinationTableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([[[requests objectAtIndex:indexPath.row] objectForKey:@"estado"] isEqualToString:@"P"]) {
        cell.status.text = @"Pendiente";
    }else if ([[[requests objectAtIndex:indexPath.row] objectForKey:@"estado"] isEqualToString:@"A"]){
        cell.status.text = @"Aprobada";
    }else if ([[[requests objectAtIndex:indexPath.row] objectForKey:@"estado"] isEqualToString:@"R"]){
        cell.status.text = @"Rechazada";
    }
    
    cell.destination.text = [NSString stringWithFormat:@"%@ %@",[[[[requests objectAtIndex:indexPath.row] objectForKey:@"ubicacionPasajero"] objectForKey:@"pasajero"] objectForKey:@"firstName"],[[[[requests objectAtIndex:indexPath.row] objectForKey:@"ubicacionPasajero"] objectForKey:@"pasajero"] objectForKey:@"lastName"]];
    cell.destination.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
    cell.destination.textColor = [UIColor blackColor];
    
    cell.backgroundColor=[UIColor clearColor];
    
    [cell layoutIfNeeded];
    [cell setNeedsLayout];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(DestinationTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.logo.layer.cornerRadius = cell.logo.frame.size.width/2;
    cell.logo.layer.borderWidth = 1;
    cell.logo.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.logo.clipsToBounds = YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showRequest" sender:self];
}

#pragma mark - Defauls

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HokenToken"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath*indexPath = [self.myTableView indexPathForSelectedRow];
    CheckRequestsViewController*destinationController = segue.destinationViewController;
    destinationController.userUbication = requests[indexPath.row][@"ubicacionPasajero"];
    destinationController.routeJson = requests[indexPath.row][@"ruta"][@"json"];
    destinationController.requests = requests;
    destinationController.row = indexPath.row;
}


@end
