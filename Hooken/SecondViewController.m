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
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "Header.h"

@interface SecondViewController ()<GMSMapViewDelegate,CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate>{
    GMSMapView*map;
    NSArray*temp;
    NSArray*imagesDestination;
    NSArray*destinations;
}

@property (weak, nonatomic) IBOutlet UIView *vistaMapa;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic,strong) IBOutlet UITableView* destinationsTable;

@end

@implementation SecondViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Destinos";
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor greenColor];
    [refreshControl addTarget:self action:@selector(getDestinations:) forControlEvents:UIControlEventValueChanged];
    UITableViewController *tableVC = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    [tableVC setTableView:self.destinationsTable];
    tableVC.refreshControl = refreshControl;

    self.destinationsTable.delegate=self;
    self.destinationsTable.dataSource=self;
    imagesDestination=@[@{@"json":@"",
                          @"id":@"9",
                          @"nombre":@"FCA",
                          @"logo":@"uady.jpg",
                          @"Horario":@"Lun - Vie 7 pm",
                          @"rider":@"Genner Ruiz"},
                        @{@"json":@"",
                          @"id":@"10",
                          @"nombre":@"Universidad Anáhuac Mayab",
                          @"logo":@"anahuac.png",
                          @"Horario":@"Lun - Vie 8 am",
                          @"rider":@"Carlos Vela"},
                        @{@"json":@"",
                          @"id":@"11",
                          @"nombre":@"Facultad de Ingeniería (UADY)",
                          @"logo":@"uady.jpg",
                          @"Horario":@"Lun - Mar 12 pm",
                          @"rider":@"Mauricio Ortíz"},
                        @{@"json":@"",
                          @"id":@"12",
                          @"nombre":@"Facultad de Economía (UADY)",
                          @"logo":@"uady.jpg",
                          @"Horario":@"Mier - Vie 4 pm",
                          @"rider":@"Erika Pérez"},
                        @{@"json":@"",
                          @"id":@"13",
                          @"nombre":@"Universidad Marista",
                          @"logo":@"marista.png",
                          @"Horario":@"Lun - Jue 10 am",
                          @"rider":@"Lucía Gamboa"},
                        @{@"json":@"",
                          @"id":@"14",
                          @"nombre":@"Universidad del Valle de México (UVM)",
                          @"logo":@"UVM.png",
                          @"Horario":@"Jue - Vie 6 pm",
                          @"rider":@"Enrique Rueda"},
                        ];

    [self getDestinations:nil];
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
    [manager GET:[NSString stringWithFormat:@"%@/rider/api/destinos",KAUTHURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        destinations=(NSMutableArray*)responseObject;
        [self.destinationsTable reloadData];
        NSLog(@"JSON: %@", destinations);
        [refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.destinationsTable animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", (NSDictionary*)operation.responseObject);
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
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HokenToken"];
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
    
    int var = 0;
    for (int i=0; i<[imagesDestination count]; i++) {
        if ([[NSString stringWithFormat:@"%@",[[imagesDestination objectAtIndex:i] objectForKey:@"nombre"]] isEqualToString:[[destinations objectAtIndex:indexPath.row] objectForKey:@"nombre"]]) {
            var = i;
        }
    }
    cell.logo.image = [UIImage imageNamed:imagesDestination[var][@"logo"]];
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
     destinationController.nameDestination = [[destinations objectAtIndex:indexPath.row] objectForKey:@"nombre"];
     [self.destinationsTable deselectRowAtIndexPath:indexPath animated:YES];
 }

@end
