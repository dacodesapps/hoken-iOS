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

@interface ThirdViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray*requests;
}

@property (nonatomic,strong) IBOutlet UITableView* myTableView;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Solicitudes";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor greenColor];
    [refreshControl addTarget:self action:@selector(getRides:) forControlEvents:UIControlEventValueChanged];
    UITableViewController *tableVC = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    [tableVC setTableView:self.myTableView];
    tableVC.refreshControl = refreshControl;
    
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    
    requests=@[@{@"json":@"",
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

    
    //[self getRides:nil];
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
    [manager GET:@"http://69.46.5.166:8084/rider/api/solicitudRiders" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

-(void)validateRequest:(NSInteger)index status:(NSString*)status{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.myTableView animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*params=@{@"id":requests[index][@"id"],
                          @"estado":status,
                          @"fechaViaje":requests[index][@"fechaViaje"],
                          @"ruta":@{@"destino":requests[index][@"ruta"][@"destino"],
                                    @"estadoRuta":requests[index][@"ruta"][@"estadoRuta"],
                                    @"horaInicio":requests[index][@"ruta"][@"horaInicio"],
                                    @"minutoInicio":requests[index][@"ruta"][@"minutoInicio"],
                                    @"id":requests[index][@"ruta"][@"id"],
                                    @"json":requests[index][@"ruta"][@"json"],
                                    @"rider":requests[index][@"ruta"][@"rider"]},
                          @"ubicacionPasajero":@{@"abordo":[NSNumber numberWithBool:true],
                                                 @"fechaCreacion":requests[index][@"ubicacionPasajero"][@"fechaCreacion"],
                                                 @"id":requests[index][@"ubicacionPasajero"][@"id"],
                                                 @"latitud": requests[index][@"ubicacionPasajero"][@"latitud"],
                                                 @"longitud": requests[index][@"ubicacionPasajero"][@"longitud"],
                                                 @"pasajero":requests[index][@"ubicacionPasajero"][@"pasajero"]}
                          };
    NSLog(@"Params: %@",params);
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager PUT:@"http://69.46.5.166:8084/rider/api/solicitudRiders" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [MBProgressHUD hideHUDForView:self.myTableView animated:YES];
        NSDictionary*temp=(NSDictionary*)responseObject;
        NSLog(@"Edit Routes: %@", temp);
        //[self.myTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
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
    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[[[requests objectAtIndex:indexPath.row] objectForKey:@"ubicacionPasajero"] objectForKey:@"pasajero"] objectForKey:@"firstName"],[[[[requests objectAtIndex:indexPath.row] objectForKey:@"ubicacionPasajero"] objectForKey:@"pasajero"] objectForKey:@"lastName"]];
//    cell.textLabel.font = [UIFont fontWithName:@"Gotham-Book" size:14.0f];
//    cell.textLabel.textColor = [UIColor darkGrayColor];
//    if ([[[requests objectAtIndex:indexPath.row] objectForKey:@"estado"] isEqualToString:@"P"]) {
//        cell.detailTextLabel.text = @"Pendiente";
//    }else if ([[[requests objectAtIndex:indexPath.row] objectForKey:@"estado"] isEqualToString:@"A"]){
//        cell.detailTextLabel.text = @"Aprobada";
//    }else if ([[[requests objectAtIndex:indexPath.row] objectForKey:@"estado"] isEqualToString:@"R"]){
//        cell.detailTextLabel.text = @"Rechazada";
//    }
    cell.destination.text = requests[indexPath.row][@"rider"];
    cell.destination.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
    cell.destination.textColor = [UIColor blackColor];
    cell.logo.layer.cornerRadius = cell.logo.frame.size.width/2;
    cell.logo.layer.borderWidth = 3;
    cell.logo.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.logo.clipsToBounds = YES;
    
    cell.backgroundColor=[UIColor clearColor];
    
    [cell layoutIfNeeded];
    [cell setNeedsLayout];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
    alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    [alert addButton:@"Aceptar" actionBlock:^(void) {
        [self validateRequest:indexPath.row status:@"A"];
    }];
    [alert addButton:@"Rechazar" actionBlock:^(void) {
        [self validateRequest:indexPath.row status:@"R"];
    }];
    [alert showEdit:self title:@"Hoken" subTitle:@"¿Qué deseas realizar con esta solicitud?" closeButtonTitle:@"Cancelar" duration:0.0f];
}

#pragma mark - Defauls

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
