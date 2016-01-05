//
//  RoutesByDestinationViewController.m
//  Hooken
//
//  Created by Dacodes on 23/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "RoutesByDestinationViewController.h"
#import "AFNetworking.h"
#import "RequestMapViewController.h"
#import "SCLAlertView.h"
#import "MBProgressHUD.h"
#import "RoutesByDestinatonTableViewCell.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "Header.h"

@interface RoutesByDestinationViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray*routesByDestination;
    NSArray*imagesDestination;
}

@property (nonatomic,strong) IBOutlet UITableView* routesByDestinationTable;

@end

@implementation RoutesByDestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Rutas";
    self.routesByDestinationTable.delegate=self;
    self.routesByDestinationTable.dataSource=self;
    
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
    
    [self getDestinations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Routes

-(void)getDestinations{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.routesByDestinationTable animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*params=@{@"destino_id":self.idDestination};
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager GET:[NSString stringWithFormat:@"%@/rider/api/rutas",KAUTHURL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [MBProgressHUD hideHUDForView:self.routesByDestinationTable animated:YES];
        routesByDestination=(NSArray*)responseObject;
        [self.routesByDestinationTable reloadData];
        NSLog(@"JSON Routes: %@", routesByDestination);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
        [MBProgressHUD hideHUDForView:self.routesByDestinationTable animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HokenToken"];
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [routesByDestination count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    view.backgroundColor = [UIColor whiteColor];
    
    int var = 0;
    for (int i=0; i<[imagesDestination count]; i++) {
        if ([[NSString stringWithFormat:@"%@",[[imagesDestination objectAtIndex:i] objectForKey:@"nombre"]] isEqualToString:self.nameDestination]) {
            var = i;
        }
    }
    
    UIImageView* logo = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 40, 40)];
    logo.image = [UIImage imageNamed:imagesDestination[var][@"logo"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    
    [view addSubview:logo];
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(56, 8, self.view.frame.size.width - 64, 21)];
    name.text = self.nameDestination;
    name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
    
    [view addSubview:name];
    
    UILabel* subtitle = [[UILabel alloc] initWithFrame:CGRectMake(56, 30, self.view.frame.size.width - 64, 21)];
    if ([routesByDestination count] == 0) {
        subtitle.text = @"No hay rutas disponibles";
    }else if ([routesByDestination count] == 1){
        subtitle.text = [NSString stringWithFormat:@"%i ruta disponible",[routesByDestination count]];
    }else{
        subtitle.text = [NSString stringWithFormat:@"%i rutas disponibles",[routesByDestination count]];
    }
    subtitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    
    [view addSubview:subtitle];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 59, self.view.frame.size.width, 1)];
    line.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [view addSubview:line];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier=@"Cell";
    RoutesByDestinatonTableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.user.text = [NSString stringWithFormat:@"%@ %@",[[[routesByDestination objectAtIndex:indexPath.row] objectForKey:@"rider"] objectForKey:@"firstName"],[[[routesByDestination objectAtIndex:indexPath.row] objectForKey:@"rider"] objectForKey:@"lastName"]];

    cell.userPic.image = [UIImage imageNamed:@"avatar"];
    
    NSData *recoverData = [[NSData alloc] initWithBase64EncodedString:routesByDestination[indexPath.row][@"json"] options:kNilOptions];
    NSPropertyListFormat plistFormat = NSPropertyListXMLFormat_v1_0;
    NSArray* array = [NSPropertyListSerialization propertyListWithData:recoverData options:NSPropertyListImmutable format:&plistFormat error:nil];
    
    if ([array count] == 0) {
        NSString *myString = [[NSString alloc] initWithData:recoverData encoding:NSUTF8StringEncoding];
        NSArray *needle = [myString componentsSeparatedByString:@"["];
        NSString* string = needle[1];
        needle = [string componentsSeparatedByString:@"]"];
        array = [needle[0] componentsSeparatedByString:@", "];
    }
    
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<array.count; i++)
    {
        NSArray *latlongArray = [[array objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
    }
    
    NSString*encodedPolyline = [path.encodedPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [cell.mapImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?size=600x300&path=weight:8%%7Ccolor:green%%7Cenc:%@",encodedPolyline]] placeholderImage:nil];
    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm"];
//    NSDate* date = [dateFormatter dateFromString:[NSString stringWithFormat:@"Horario: %@:%@",routesByDestination[indexPath.row][@"horaInicio"],routesByDestination[indexPath.row][@"minutoInicio"]]];
//    NSString*stringDate = [dateFormatter stringFromDate:date];
    
    //cell.date.text = [NSString stringWithFormat:@"Horario: %@:%@",routesByDestination[indexPath.row][@"horaInicio"],routesByDestination[indexPath.row][@"minutoInicio"]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"]];
    NSDate* date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@:%@",routesByDestination[indexPath.row][@"horaInicio"],routesByDestination[indexPath.row][@"minutoInicio"]]];
    //    NSLog(@"%@",[NSString stringWithFormat:@"Horario: %@:%@",myRoutes[indexPath.row][@"horaInicio"],myRoutes[indexPath.row][@"minutoInicio"]]);
    //    NSString*stringDate = [NSString stringWithFormat:@"Horario: %@:%@",myRoutes[indexPath.row][@"horaInicio"],myRoutes[indexPath.row][@"minutoInicio"]];
    NSString*stringDate = [dateFormatter stringFromDate:date];
    
    cell.date.text = [NSString stringWithFormat:@"Horario: %@",stringDate];
    
    [cell layoutIfNeeded];
    [cell setNeedsLayout];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(RoutesByDestinatonTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.mapImage.layer.cornerRadius = 3;
    cell.mapImage.layer.borderWidth = 1;
    cell.mapImage.layer.borderColor = [UIColor clearColor].CGColor;
    cell.mapImage.clipsToBounds=YES;
    cell.mapImage.layer.masksToBounds=YES;
    
    cell.userPic.layer.cornerRadius = cell.userPic.frame.size.width/2;
    cell.userPic.layer.borderWidth = 1;
    cell.userPic.layer.borderColor = [UIColor clearColor].CGColor;
    cell.userPic.clipsToBounds = YES;
    cell.userPic.layer.masksToBounds = YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath* indexPath = [self.routesByDestinationTable indexPathForSelectedRow];
    RequestMapViewController*destinationController = segue.destinationViewController;
    destinationController.routeJson = routesByDestination[indexPath.row][@"json"];
    destinationController.routeDestination = routesByDestination[indexPath.row][@"destino"];
    destinationController.routeStatus = routesByDestination[indexPath.row][@"estadoRuta"];
    destinationController.idRoute = routesByDestination[indexPath.row][@"id"];
    destinationController.riderInfo = routesByDestination[indexPath.row][@"rider"];
    [self.routesByDestinationTable deselectRowAtIndexPath:indexPath animated:YES];
}


@end
