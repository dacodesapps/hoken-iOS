//
//  CheckRequestsViewController.m
//  Hooken
//
//  Created by Dacodes on 30/12/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "CheckRequestsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SCLAlertView.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "Header.h"

@interface CheckRequestsViewController ()<GMSMapViewDelegate, CLLocationManagerDelegate>{
    GMSMapView*map;
}

@property (weak, nonatomic) IBOutlet UIView *vistaMapa;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation CheckRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
    marker.position = CLLocationCoordinate2DMake([self.userUbication[@"latitud"] floatValue], [self.userUbication[@"longitud"] floatValue]);
    NSLog(@"%@",self.userUbication);
    marker.title = [NSString stringWithFormat:@"%@ %@",self.userUbication[@"pasajero"][@"firstName"],self.userUbication[@"pasajero"][@"lastName"]];
    marker.snippet = @"Hoken";
    marker.map = map;
    
    [self drawRoute];
    [self fitBounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

-(void)validateRequest:(NSInteger)index status:(NSString*)status{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary*params=@{@"id":self.requests[index][@"id"],
                          @"estado":status,
                          @"fechaViaje":self.requests[index][@"fechaViaje"],
                          @"ruta":@{@"destino":self.requests[index][@"ruta"][@"destino"],
                                    @"estadoRuta":self.requests[index][@"ruta"][@"estadoRuta"],
                                    @"horaInicio":self.requests[index][@"ruta"][@"horaInicio"],
                                    @"minutoInicio":self.requests[index][@"ruta"][@"minutoInicio"],
                                    @"id":self.requests[index][@"ruta"][@"id"],
                                    @"json":self.requests[index][@"ruta"][@"json"],
                                    @"rider":self.requests[index][@"ruta"][@"rider"]},
                          @"ubicacionPasajero":@{@"abordo":[NSNumber numberWithBool:true],
                                                 @"fechaCreacion":self.requests[index][@"ubicacionPasajero"][@"fechaCreacion"],
                                                 @"id":self.requests[index][@"ubicacionPasajero"][@"id"],
                                                 @"latitud": self.requests[index][@"ubicacionPasajero"][@"latitud"],
                                                 @"longitud": self.requests[index][@"ubicacionPasajero"][@"longitud"],
                                                 @"pasajero":self.requests[index][@"ubicacionPasajero"][@"pasajero"]}
                          };
    NSLog(@"Params: %@",params);
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager PUT:[NSString stringWithFormat:@"%@/rider/api/solicitudRiders",KAUTHURL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}


-(IBAction)respondRequest:(id)sender{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    alert.circleIconImageView.image=[UIImage imageNamed:@"logo.png"];
    alert.customViewColor=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    [alert addButton:@"Aceptar" actionBlock:^(void) {
        [self validateRequest:self.row status:@"A"];
    }];
    [alert addButton:@"Rechazar" actionBlock:^(void) {
        [self validateRequest:self.row status:@"R"];
    }];
    [alert showEdit:self title:@"Hoken" subTitle:@"¿Qué deseas realizar con esta solicitud?" closeButtonTitle:@"Cancelar" duration:0.0f];
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
