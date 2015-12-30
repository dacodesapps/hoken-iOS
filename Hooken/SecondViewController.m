//
//  SecondViewController.m
//  Hooken
//
//  Created by Dacodes on 17/10/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "SecondViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "RoutesByDestinationViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "DestinationTableViewCell.h"

@interface SecondViewController ()<GMSMapViewDelegate,CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate>{
    GMSMapView*map;
    NSArray*temp;
    //NSMutableArray*destinations;
    NSArray*destinations;
}

@property (weak, nonatomic) IBOutlet UIView *vistaMapa;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic,strong) IBOutlet UITableView* destinationsTable;

@end

@implementation SecondViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    temp=@[@"New York, NY", @"Los Angeles, CA", @"Chicago, IL", @"Houston, TX",
//           @"Philadelphia, PA", @"Phoenix, AZ", @"San Diego, CA", @"San Antonio, TX",
//           @"Dallas, TX", @"Detroit, MI", @"San Jose, CA", @"Indianapolis, IN",
//           @"Jacksonville, FL", @"San Francisco, CA", @"Columbus, OH", @"Austin, TX",
//           @"Memphis, TN", @"Baltimore, MD", @"Charlotte, ND", @"Fort Worth, TX"];
//    
//    self.searchBar = [[UISearchBar alloc] init];
//    [self.searchBar sizeToFit];
//    self.searchBar.delegate = self;
//    
//    self.navigationItem.titleView = self.searchBar;
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
//    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    
//    // Check for iOS 8
//    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    
//    [self.locationManager startUpdatingLocation];
//    self.locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
//    self.locationManager.distanceFilter = 10.0f;
//    self.locationManager.headingFilter = 5;
//    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:12];
//    map=[GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49) camera:camera];
//    
//    map.delegate=self;
//    map.settings.myLocationButton = YES;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        map.myLocationEnabled = YES;
//    });
//    [self.vistaMapa addSubview:map];
//}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Destinos";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],NSForegroundColorAttributeName : [UIColor blackColor]}];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor greenColor];
    [refreshControl addTarget:self action:@selector(getDestinations:) forControlEvents:UIControlEventValueChanged];
    UITableViewController *tableVC = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    [tableVC setTableView:self.destinationsTable];
    tableVC.refreshControl = refreshControl;

    self.destinationsTable.delegate=self;
    self.destinationsTable.dataSource=self;
    destinations=@[@{@"clave":@"",
                   @"id":@"9",
                   @"nombre":@"FCA",
                     @"logo":@"uady.jpg"},
                 @{@"clave":@"",
                   @"id":@"10",
                   @"nombre":@"Universidad Anáhuac Mayab",
                   @"logo":@"anahuac.png"},
                 @{@"clave":@"",
                   @"id":@"11",
                   @"nombre":@"Facultad de Ingeniería (UADY)",
                   @"logo":@"uady.jpg"},
                 @{@"clave":@"",
                   @"id":@"12",
                   @"nombre":@"Facultad de Economía (UADY)",
                   @"logo":@"uady.jpg"},
                 @{@"clave":@"",
                   @"id":@"13",
                   @"nombre":@"Universidad Marista",
                   @"logo":@"marista.png"},
                 @{@"clave":@"",
                   @"id":@"14",
                   @"nombre":@"Universidad del Valle de México (UVM)",
                   @"logo":@"UVM.png"},
                 ];
    //[self getDestinations:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Routes

-(void)getDestinations:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.destinationsTable animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    UIRefreshControl*refreshControl = (UIRefreshControl *)sender;
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager GET:@"http://69.46.5.166:8084/rider/api/destinos" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        destinations=(NSMutableArray*)responseObject;
        [self.destinationsTable reloadData];
        NSLog(@"JSON: %@", destinations);
        [refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.destinationsTable animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
        [refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.destinationsTable animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
}

//#pragma mark - SearchBar
//
//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//}
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    if (self.resultsTable == nil) {
//        self.resultsTable = [[UITableView alloc]initWithFrame:CGRectMake(16, self.view.frame.size.height, self.view.frame.size.width-32, self.view.frame.size.height-64-44-50)];
//        self.resultsTable.delegate=self;
//        self.resultsTable.dataSource=self;
//        self.resultsTable.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:1.0];
//        [self.vistaMapa addSubview:self.resultsTable];
//    }
//    [UIView animateWithDuration:.2 animations:^{
//        self.resultsTable.frame=CGRectMake(16, 68, self.view.frame.size.width-32, self.view.frame.size.height-88);
//    }];
//    self.resultsTable.layer.cornerRadius=10;
//    [searchBar setShowsCancelButton:YES animated:YES];
//    //self.searchBar.showsCancelButton=YES;
//    //  self.myTableView.allowsSelection = NO;
//    //self.myTableView.scrollEnabled = NO;
//    //self.myCollectionView.scrollEnabled=NO;
//}
//
//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    //[self performSelector:@selector(enableCancelButton:) withObject:searchBar afterDelay:0.0];
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [UIView animateWithDuration:.2 animations:^{
//        self.resultsTable.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-64-88-50);
//    }];
//    //searchBar.text=@"";
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    //keyword=@"";
//    //page=1;
//    //[self getSales:nil];
//    //self.myTableView.allowsSelection = YES;
//    //self.myTableView.scrollEnabled = YES;
//    //self.myCollectionView.scrollEnabled=YES;
//}
//
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    //[self.myCollectionView reloadData];
//    //self.myCollectionView.scrollEnabled=YES;
//    //keyword=searchBar.text;
//    //page=1;
//    //[self getSales:nil];
//    //    [UIView animateWithDuration:.2 animations:^{
//    //        self.backView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
//    //        self.resultsTable.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-64-88-50);
//    //    }];
//    [searchBar resignFirstResponder];
//}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [destinations count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier=@"Cell";
    DestinationTableViewCell* cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    if(!cell){
//        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    
    cell.destination.text = [[destinations objectAtIndex:indexPath.row] objectForKey:@"nombre"];
    //cell.destination.font = [UIFont fontWithName:@"Gotham-Book" size:14.0f];
    cell.destination.textColor = [UIColor blackColor];
    cell.backgroundColor=[UIColor clearColor];
    //cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.logo.image = [UIImage imageNamed:destinations[indexPath.row][@"logo"]];
    cell.logo.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     NSIndexPath*indexPath = [self.destinationsTable indexPathForSelectedRow];
     RoutesByDestinationViewController*destinationController = segue.destinationViewController;
     destinationController.idDestination = [[destinations objectAtIndex:indexPath.row] objectForKey:@"id"];
     [self.destinationsTable deselectRowAtIndexPath:indexPath animated:YES];
 }

@end
