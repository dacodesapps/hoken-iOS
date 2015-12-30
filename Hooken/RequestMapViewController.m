//
//  RequestMapViewController.m
//  Hooken
//
//  Created by Dacodes on 25/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "RequestMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"

@interface RequestMapViewController ()<CLLocationManagerDelegate,GMSMapViewDelegate>{
    GMSMapView*map;
}

@property (weak, nonatomic) IBOutlet UIView *vistaMapa;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation RequestMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:12];
    map=[GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-113) camera:camera];
    
    map.delegate=self;
    map.settings.compassButton = YES;
    map.settings.myLocationButton = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        map.myLocationEnabled = YES;
    });
    [self.vistaMapa addSubview:map];
    
    [self drawRoute];
    [self fitBounds];
}

#pragma mark - Map Routes

-(void)drawRoute{
    NSData *recoverData = [[NSData alloc] initWithBase64EncodedString:self.routeJson options:kNilOptions];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:recoverData];
    NSLog(@"%@",self.routeJson);
    NSLog(@"%@",array);
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<array.count; i++)
    {
        NSArray *latlongArray = [[array objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
    }
    
    //    if (points.count>2) {
    //        //[self ruta:[points objectAtIndex:[points count]-1] and:[points objectAtIndex:[points count]-2]];
    //        [self drawRoute:[points objectAtIndex:[points count]-1] and:[points objectAtIndex:[points count]-2]];
    //    }
    
    if (array.count>2)
    {
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
        polyline.strokeWidth = 5.f;
        polyline.map = map;
    }
}

- (void)fitBounds {
    GMSCoordinateBounds *bounds;
    
    NSData *recoverData = [[NSData alloc] initWithBase64EncodedString:self.routeJson options:kNilOptions];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:recoverData];
    
    for (int i=0; i<[array count]; i++) {
        NSArray *latlongArray = [[array objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        if (bounds == nil) {
            bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake([[latlongArray objectAtIndex:0] doubleValue], [[latlongArray objectAtIndex:1] doubleValue])
                                                          coordinate:CLLocationCoordinate2DMake([[latlongArray objectAtIndex:0] doubleValue], [[latlongArray objectAtIndex:1] doubleValue])];
        }
        bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake([[latlongArray objectAtIndex:0] doubleValue], [[latlongArray objectAtIndex:1] doubleValue])];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:50.0f];
    [map moveCamera:update];
}

#pragma mark - Actions

-(IBAction)requestRide:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*params=@{@"id":[NSNull null],
                          @"latitud": [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude],
                          @"longitud": [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude],
                          @"estado":@"",
                          @"fechaViaje":@"2015-11-26T14:05:29.571Z",
                          @"ruta":@{@"destino":self.routeDestination,
                                    @"estadoRuta":self.routeStatus,
                                    @"horaInicio":@"1",
                                    @"minutoInicio":@"1",
                                    @"id":self.idRoute,
                                    @"json":self.routeJson,
                                    @"rider":self.riderInfo}
                              };
    NSLog(@"%@",params);
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager POST:@"http://69.46.5.166:8084/rider/api/solicitudRiders" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary*temp=(NSDictionary*)responseObject;
        NSLog(@"Request Route: %@", temp);
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
        //alert.labelTitle.font=[UIFont fontWithName:@"Dosis-Bold" size:18.0];
        //alert.viewText.font=[UIFont fontWithName:@"Oswald-Regular" size:16.0];
        alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
        [alert addButton:@"Aceptar" actionBlock:^(void) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alert showEdit:self title:@"Hoken" subTitle:@"Se solocitó correctamente un aventón." closeButtonTitle:nil duration:0.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.error.code == -1011) {
            //NSLog(@"Error: %li", operation.error.code);
        }else{
            //NSLog(@"Error: %li", operation.error.code);
            NSLog(@"Error: %@", error);
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Defauls

-(NSString*)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
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
