//
//  MapViewController.m
//  Hooken
//
//  Created by Dacodes on 04/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "AFNetworking.h"
#import "SCLAlertView.h"
#import "MBProgressHUD.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "Header.h"

@interface MapViewController ()<CLLocationManagerDelegate,GMSMapViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    GMSMapView*map;
    NSMutableArray*points;
    NSDictionary*jsonObject;
    BOOL tracking;
    GMSPolyline *polyline;
    
    UIView *maskView;
    UIPickerView *pickerView;
    UIToolbar *toolBar;
    NSInteger indexSelected;
    NSString *rolSelected;
    NSArray*rolOptions;
    NSArray *rolSelectedKey;
    NSArray*rolOptionsKeys;
}

@property (weak, nonatomic) IBOutlet UIView *vistaMapa;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tracking = NO;
    
    self.title = @"Mapa";
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    //self.locationManager.distanceFilter = 100.0f;
    //self.locationManager.headingFilter = 5;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:12];
    map=[GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-113) camera:camera];
    
    map.delegate=self;
    map.settings.compassButton = YES;
    map.settings.myLocationButton = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        map.myLocationEnabled = YES;
    });
    [self.vistaMapa addSubview:map];
    
    points = [[NSMutableArray alloc] init];
    
    indexSelected=0;
    tracking = NO;
    
    [self getDestinations:nil];
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

- (void)createPickerView{
    [self.view endEditing:YES];
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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
    [maskView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[picker]|" options:0 metrics:nil views:@{@"picker":pickerView}]];

    toolBar = [[UIToolbar alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints=NO;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissActionSheet:)];
    [done setTintColor:[UIColor whiteColor]];
    toolBar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done];
    toolBar.barTintColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    toolBar.translucent=NO;
    [maskView addSubview:toolBar];
    [maskView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar]-[picker]|" options:0 metrics:nil views:@{@"toolBar":toolBar,@"picker":pickerView}]];
    [maskView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolBar]|" options:0 metrics:nil views:@{@"toolBar":toolBar,@"picker":pickerView}]];
}

- (void)dismissActionSheet:(id)sender{
    [self createRoute];
    [maskView removeFromSuperview];
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
    indexSelected=row;
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
    tView.text=rolOptions[row][@"nombre"];
    return tView;
}

#pragma mark -Actions

-(IBAction)startTracking:(id)sender{
    if (tracking) {
        UIBarButtonItem*button=[[UIBarButtonItem alloc] initWithTitle:@"Iniciar trayecto" style:UIBarButtonItemStylePlain target:self action:@selector(startTracking:)];
        self.navigationItem.rightBarButtonItems=@[button];
        tracking = NO;
        [self createPickerView];
    }else{
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
        alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
        [alert addButton:@"Iniciar trayecto" actionBlock:^(void) {
            points = [[NSMutableArray alloc] init];
            UIBarButtonItem*button=[[UIBarButtonItem alloc] initWithTitle:@"Terminar trayecto" style:UIBarButtonItemStylePlain target:self action:@selector(startTracking:)];
            self.navigationItem.rightBarButtonItems=@[button];
            tracking = YES;
        }];
        [alert showEdit:self title:@"Hoken" subTitle:@"Para agregar una nueva ruta, comienza a conducir por el trayecto deseado. Hoken grabará la trayectoria recorrida utilizando el GPS de tu teléfono móvil." closeButtonTitle:@"Cancelar" duration:0.0f];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"Enter");
    if (tracking) {
        NSLog(@"Updating Location");
        NSString *pointString=[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
        [points addObject:pointString];
        GMSMutablePath *path = [GMSMutablePath path];
        for (int i=0; i<points.count; i++)
        {
            NSArray *latlongArray = [[points objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            
            [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
        }
        
        //    if (points.count>2) {
        //        //[self ruta:[points objectAtIndex:[points count]-1] and:[points objectAtIndex:[points count]-2]];
        //        [self drawRoute:[points objectAtIndex:[points count]-1] and:[points objectAtIndex:[points count]-2]];
        //    }
        
        if (points.count>2)
        {
            polyline = [GMSPolyline polylineWithPath:path];
            polyline.strokeColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
            polyline.strokeWidth = 5.f;
            polyline.map = map;
        }
    }
}

#pragma mark - Routes

-(void)getDestinations:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager GET:[NSString stringWithFormat:@"%@/rider/api/destinos",KAUTHURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        rolOptions=(NSArray*)responseObject;
        rolSelected=rolOptions[0];
        NSLog(@"JSON: %@", rolOptions);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", (NSDictionary*)operation.responseObject);
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

-(void)createRoute{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando Ruta", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //NSArray*jsonRoute = [NSArray arrayWithArray:points];
//    NSData *plainData = [NSKeyedArchiver archivedDataWithRootObject:jsonRoute];
    NSArray*jsonRoute = @[@"21.024933,-89.595710",
                          @"21.024930,-89.595632",
                          @"21.024909,-89.595586",
                          @"21.024832,-89.595594",
                          @"21.024762,-89.595573",
                          @"21.024688,-89.595633",
                          @"21.024616,-89.595677",
                          @"21.024517,-89.595726",
                          @"21.024418,-89.595754",
                          @"21.024309,-89.595804",
                          @"21.024195,-89.595849",
                          @"21.024082,-89.595922",
                          @"21.023956,-89.595963"];
    
    NSData * plainData = [NSPropertyListSerialization dataWithPropertyList:points format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:nil];
    NSString *base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    }
    
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString*stringDate = [dateFormatter stringFromDate:date];
    NSArray*todayDate = [stringDate componentsSeparatedByString:@":"];
    
    NSDictionary*parameters=@{@"destino": rolSelected,
                              @"estadoRuta": @{@"clave":@"INI",
                                               @"id":@"1",
                                               @"nombre":@"Iniciada"},
                              @"horaInicio":todayDate[0],
                              @"id":[NSNull null],
                              @"json":base64String,
                              @"minutoInicio":todayDate[1],
                              @"rider":@{@"activated":[NSNumber numberWithBool:true],
                                         @"email":self.email,
                                         @"firstName":self.firstName,
                                         @"id":self.idUser,
                                         @"langKey":@"es",
                                         @"lastName":self.lastName,
                                         @"login":[self login],
                                         @"resetDate":[NSNull null],
                                         @"resetKey":[NSNull null],
                                         @"uidsocial":[NSNull null]}
                              };
    NSLog(@"%@",parameters);
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager POST:[NSString stringWithFormat:@"%@/rider/api/rutas",KAUTHURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [hud hide:YES];
        NSDictionary*temp=(NSDictionary*)responseObject;
        NSData *recoverData = [[NSData alloc] initWithBase64EncodedString:temp[@"json"] options:kNilOptions];
        NSString *myString = [[NSString alloc] initWithData:recoverData encoding:NSUTF8StringEncoding];

//        NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:recoverData];
//        NSLog(@"Route: %@", temp);
//        NSLog(@"JSON: %@", array);
        
        NSArray* plist;
        NSPropertyListFormat plistFormat = NSPropertyListXMLFormat_v1_0;
        plist = [NSPropertyListSerialization propertyListWithData:recoverData options:NSPropertyListImmutable format:&plistFormat error:nil];
        NSLog(@"Route: %@", temp);
        NSLog(@"XML: %@", plist);
        NSLog(@"String: %@", myString);
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
        //alert.labelTitle.font=[UIFont fontWithName:@"Dosis-Bold" size:18.0];
        //alert.viewText.font=[UIFont fontWithName:@"Oswald-Regular" size:16.0];
        alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
        [alert addButton:@"Aceptar" actionBlock:^(void) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadTable" object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alert showEdit:self title:@"Hoken" subTitle:@"Se añadió exitosamente la ruta" closeButtonTitle:nil duration:0.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %i", operation.error.code);
            NSLog(@"Error: %@", (NSDictionary*) operation.responseObject);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", (NSDictionary*) operation.responseObject);
            NSLog(@"Error: %@", error);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

-(void)createDestination{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*params = @{@"clave":@"",
                            @"id":[NSNull null],
                            @"nombre":@"Universidad Anáhuac Mayab"};

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager POST:[NSString stringWithFormat:@"%@/rider/api/destinos",KAUTHURL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        NSDictionary*temp=(NSDictionary*)responseObject;
        NSLog(@"JSON: %@", temp);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary*temp=(NSDictionary*)operation.responseObject;
        NSLog(@"%@",temp);
        if (operation.error.code == -1011) {
            NSLog(@"Error: %@", error);
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

//https://maps.googleapis.com/maps/api/directions/json
//http://maps.googleapis.com/maps/api/directions/json

//- (void)ruta:(NSString*)location and:(NSString*)destination{
//    NSArray *latlongArray = [location componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//    NSArray *latlongArray2 = [destination componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *urlAsString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@,%@&destination=%@,%@&region=mx&sensor=false",[latlongArray objectAtIndex:0],[latlongArray objectAtIndex:1],[latlongArray2 objectAtIndex:0],[latlongArray2 objectAtIndex:1]];
//        //NSString *urlAsString = @"http://maps.googleapis.com/maps/api/directions/json?origin=21.029854,-89.626350&destination=21.110565,-89.611305&region=mx&sensor=false";
//        NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlAsString]];
//        NSInputStream *stream = [[NSInputStream alloc] initWithData:response];
//        [stream open];
//        if(stream)
//        {
//            NSError *parseError = nil;
//            jsonObject = [NSJSONSerialization JSONObjectWithStream:stream options:NSJSONReadingAllowFragments error:&parseError];
//            NSLog(@"%@",jsonObject);
//            //NSLog(@"%@",jsonObject);
//        }
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            NSDictionary *routes = [[jsonObject objectForKey:@"routes"]objectAtIndex:0];
//            NSDictionary *route = [routes objectForKey:@"overview_polyline"];
//            NSString *overview_route = [route objectForKey:@"points"];
//            NSLog(@"%@",overview_route);
//            GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
//            //GMSPath *path = [GMSPath pathFromEncodedPath:@"yzf_Cds}aPsBJo@HaAT_A\\iC`BkBtAkHzFaFxDy@r@oDrC}DvCsCzB_IbGEAo@l@kG~EyDtC{AnAiCnBuC|Bo@`@eAp@QPMHSPc@RyCz@uC~@kAn@y@l@iDzBu@Zo@R{Db@sBNW?ECIEO?OBKFGJqD^_P~AaNlA_MjAqCP"];
//            GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
//            polyline.map = map;
//            polyline.strokeWidth=5.0f;
//            polyline.geodesic=YES;
//            polyline.strokeColor=[UIColor colorWithRed:118.0/255.0 green:111.0/255.0 blue:178.0/255.0 alpha:1];
//        });
//    });
//}

-(void)drawRoute:(NSString*)location and:(NSString*)destination{
    NSArray *latlongArray = [location componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSArray *latlongArray2 = [destination componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *urlAsString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@,%@&destination=%@,%@&region=mx&sensor=false",[latlongArray objectAtIndex:0],[latlongArray objectAtIndex:1],[latlongArray2 objectAtIndex:0],[latlongArray2 objectAtIndex:1]];
    //NSString *urlAsString = @"http://maps.googleapis.com/maps/api/directions/json?origin=21.029854,-89.626350&destination=21.110565,-89.611305&region=mx&sensor=false";
    [manager GET:urlAsString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        jsonObject=(NSDictionary*)responseObject;
        //NSLog(@"JSON: %@", jsonObject);
        NSDictionary *routes = [[jsonObject objectForKey:@"routes"]objectAtIndex:0];
        NSDictionary *route = [routes objectForKey:@"overview_polyline"];
        NSString *overview_route = [route objectForKey:@"points"];
        NSLog(@"%@",overview_route);
        GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
        //GMSPath *path = [GMSPath pathFromEncodedPath:@"yzf_Cds}aPsBJo@HaAT_A\\iC`BkBtAkHzFaFxDy@r@oDrC}DvCsCzB_IbGEAo@l@kG~EyDtC{AnAiCnBuC|Bo@`@eAp@QPMHSPc@RyCz@uC~@kAn@y@l@iDzBu@Zo@R{Db@sBNW?ECIEO?OBKFGJqD^_P~AaNlA_MjAqCP"];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.map = map;
        polyline.strokeWidth=5.0f;
        polyline.geodesic=YES;
        polyline.strokeColor=[UIColor colorWithRed:118.0/255.0 green:111.0/255.0 blue:178.0/255.0 alpha:1];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

#pragma mark - Defauls

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HokenToken"];
}

-(NSString*)login{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
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
