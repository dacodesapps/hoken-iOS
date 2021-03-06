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
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "Header.h"

@interface RequestMapViewController ()<CLLocationManagerDelegate,GMSMapViewDelegate>{
    GMSMapView*map;
    GMSMarker *marker;
}

@property (weak, nonatomic) IBOutlet UIView *vistaMapa;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation RequestMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ruta";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
    
    marker = [[GMSMarker alloc] init];
    
    [self drawRoute];
    [self fitBounds];
}

#pragma mark - Map Routes

-(void)drawRoute{
    NSData *recoverData = [[NSData alloc] initWithBase64EncodedString:self.routeJson options:kNilOptions];
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
    NSPropertyListFormat plistFormat = NSPropertyListXMLFormat_v1_0;
    NSArray* array = [NSPropertyListSerialization propertyListWithData:recoverData options:NSPropertyListImmutable format:&plistFormat error:nil];
    
    if ([array count] == 0) {
        NSString *myString = [[NSString alloc] initWithData:recoverData encoding:NSUTF8StringEncoding];
        NSArray *needle = [myString componentsSeparatedByString:@"["];
        NSString* string = needle[1];
        needle = [string componentsSeparatedByString:@"]"];
        array = [needle[0] componentsSeparatedByString:@", "];
    }
    
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

//-(void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
//    marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
//    marker.position = coordinate;
//    marker.title = @"Mi Posicion";
//    marker.snippet = @"Hoken";
//    marker.map = map;
//}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
    marker.position = coordinate;
    marker.title = @"Mi Posicion";
    marker.snippet = @"Hoken";
    marker.map = map;
    marker.draggable = YES;
}

#pragma mark - Actions

-(IBAction)requestRide:(id)sender{
    
    if ([marker.title length] == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
        alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
        [alert addButton:@"Aceptar" actionBlock:^(void) {
            return;
        }];
        [alert showEdit:self title:@"Hoken" subTitle:@"Tienes que solicitar un punto de encuentro con el conductor para pedir un aventón." closeButtonTitle:nil duration:0.0f];
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString*stringDate = [dateFormatter stringFromDate:date];
    NSArray*todayDate = [stringDate componentsSeparatedByString:@":"];
    
    NSDictionary*params=@{@"id":[NSNull null],
                          @"latitud": [NSString stringWithFormat:@"%f",marker.position.latitude],
                          @"longitud": [NSString stringWithFormat:@"%f",marker.position.longitude],
                          @"estado":@"",
                          @"fechaViaje":@"2015-11-26T14:05:29.571Z",
                          @"ruta":@{@"destino":self.routeDestination,
                                    @"estadoRuta":self.routeStatus,
                                    @"horaInicio":todayDate[0],
                                    @"minutoInicio":todayDate[1],
                                    @"id":self.idRoute,
                                    @"json":self.routeJson,
                                    @"rider":self.riderInfo}
                              };
    NSLog(@"%@",params);
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager POST:[NSString stringWithFormat:@"%@/rider/api/solicitudRiders",KAUTHURL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary*temp=(NSDictionary*)responseObject;
        NSLog(@"Request Route: %@", temp);
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
        alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
        [alert addButton:@"Aceptar" actionBlock:^(void) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alert showEdit:self title:@"Hoken" subTitle:@"Se solocitó correctamente un aventón." closeButtonTitle:nil duration:0.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", (NSDictionary*)operation.responseObject);
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
