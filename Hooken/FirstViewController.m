//
//  FirstViewController.m
//  Hooken
//
//  Created by Dacodes on 17/10/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "FirstViewController.h"
#import "MBTwitterScroll.h"
#import "MapRoutesTableViewCell.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "MapViewController.h"
#import "MBProgressHUD.h"
#import "MyRoutesViewController.h"
#import "UIButton+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Security/Security.h>
#import "KeychainItemWrapper.h"

@interface FirstViewController ()<UITableViewDelegate, UITableViewDataSource, MBTwitterScrollDelegate>{
    NSDictionary* profileAccount;
    NSArray*myRoutes;
    NSInteger routeSelected;
    NSMutableArray*disponible;
}

@property (nonatomic,strong) MBTwitterScroll* myTableView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Regresar" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (self.fromLoginOrRegister) {
        [self getAccount];
    }else{
        [self setUpProfileView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRoutes) name:@"reloadTable" object:nil];
    
    myRoutes=@[@{@"json":@"",
                     @"id":@"9",
                     @"nombre":@"FCA",
                     @"logo":@"uady.jpg",
                 @"Horario":@"Lun - Vie 7 pm"},
                   @{@"json":@"",
                     @"id":@"10",
                     @"nombre":@"Universidad Anáhuac Mayab",
                     @"logo":@"anahuac.png",
                     @"Horario":@"Lun - Vie 8 am"},
                   @{@"json":@"",
                     @"id":@"11",
                     @"nombre":@"Facultad de Ingeniería (UADY)",
                     @"logo":@"uady.jpg",
                     @"Horario":@"Lun - Mar 12 pm"},
                   @{@"json":@"",
                     @"id":@"12",
                     @"nombre":@"Facultad de Economía (UADY)",
                     @"logo":@"uady.jpg",
                     @"Horario":@"Mier - Vie 4 pm"},
                   @{@"json":@"",
                     @"id":@"13",
                     @"nombre":@"Universidad Marista",
                     @"logo":@"marista.png",
                     @"Horario":@"Lun - Jue 10 am"},
                   @{@"json":@"",
                     @"id":@"14",
                     @"nombre":@"Universidad del Valle de México (UVM)",
                     @"logo":@"UVM.png",
                     @"Horario":@"Jue - Vie 6 pm"},
               ];
    
    NSArray*temp = @[@"Disponible",@"Disponible",@"Disponible",@"Disponible",@"Disponible",@"Disponible"];
    disponible = [NSMutableArray arrayWithArray:temp];
 }

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

-(void)reloadRoutes{
    [self getRoutes];
}

- (void)dealloc
{
    // Clean up; make sure to add this
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setUpProfileView{
    self.myTableView = [[MBTwitterScroll alloc]
                                    initTableViewWithBackgound:[UIImage imageNamed:@"Cover"]
                                    avatarImage:[UIImage imageNamed:@"avatar.png"]
                                    titleString:[NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName]
                                    subtitleString:@"Mis Rutas"
                                    buttonTitle:@"Crear Ruta"
                                    rating:4
                                    userType:self.role];  // Set nil for no button
    
    self.myTableView.tableView.delegate = self;
    self.myTableView.tableView.dataSource = self;
    self.myTableView.tableView.separatorColor = [UIColor clearColor];
    self.myTableView.delegate = self;
    self.myTableView.tableView.allowsSelection=NO;
    [self.view addSubview:self.myTableView];
    [self getRoutes];
}

#pragma mark - Actions

- (void) recievedMBTwitterScrollEvent {
    //[self performSegueWithIdentifier:@"showPopover" sender:self];
    NSLog(@"Scroll Event");
}

- (void) recievedMBTwitterScrollButtonClicked {
    NSLog(@"Button Clicked");
    [self goMap:nil];
}

- (void)goMap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"map" sender:self];
    });
}

- (void)goMyRoute:(id)sender {
    routeSelected = [sender tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"myroute" sender:self];
    });
}

#pragma mark - TableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [myRoutes count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"Cell";
    MapRoutesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MapRoutesTableViewCell" owner:self options:nil];
        cell = (MapRoutesTableViewCell *)[nib objectAtIndex:0];
    }
    
    cell.logo.image = [UIImage imageNamed:myRoutes[indexPath.row][@"logo"]];
    cell.logo.contentMode = UIViewContentModeScaleAspectFit;
    
    cell.destination.text = myRoutes[indexPath.row][@"nombre"];
    
    cell.mapButton.tag=indexPath.row;
    [cell.mapButton addTarget:self action:@selector(goMyRoute:) forControlEvents:UIControlEventTouchUpInside];
    
    NSData *recoverData = [[NSData alloc] initWithBase64EncodedString:myRoutes[indexPath.row][@"json"] options:kNilOptions];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:recoverData];
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<array.count; i++)
    {
        NSArray *latlongArray = [[array objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
    }
    
    NSString*encodedPolyline = [path.encodedPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [cell.mapButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?size=600x260&path=weight:8%%7Ccolor:green%%7Cenc:%@",encodedPolyline]] forState:UIControlStateNormal];
    
    if ([disponible[indexPath.row] isEqualToString:@"Disponible"]) {
        [cell.availableSwitch setOn:YES];
    }else{
        [cell.availableSwitch setOn:NO];
    }
    cell.availableSwitch.onTintColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    cell.availableSwitch.tintColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    [cell.availableSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    cell.availableSwitch.tag = indexPath.row;
    
    cell.date.text = myRoutes[indexPath.row][@"Horario"];
    
    cell.available.text = disponible[indexPath.row];

//    cell.mapButton.layer.cornerRadius = 10;
//    cell.mapButton.layer.borderWidth = 3;
//    cell.mapButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    
//    [cell layoutIfNeeded];
//    [cell setNeedsLayout];
    
    //cell.textLabel.text =  @"Cell";
    //cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)changeSwitch:(id)sender{
    if([sender isOn]){
        NSLog(@"Switch is ON");
        disponible[[sender tag]] = @"Disponible";
    } else{
        NSLog(@"Switch is OFF");
        disponible[[sender tag]] = @"No Disponible";
    }
    [self.myTableView.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sender tag] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Session

- (IBAction)logOut:(id)sender {
    [self setUserAuthentication:NO];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* login = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
    appDelegateTemp.window.rootViewController = login;
}

-(void)getAccount{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager GET:[NSString stringWithFormat:@"http://69.46.5.166:8084/rider/api/users/%@",[self login]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [hud hide:YES];
        profileAccount=(NSDictionary*)responseObject;
        self.firstName=profileAccount[@"firstName"];
        self.lastName=profileAccount[@"lastName"];
        self.email=profileAccount[@"email"];
        self.idUser=profileAccount[@"id"];
        if ([profileAccount[@"authorities"] containsObject:@"ROLE_RIDER"]) {
            self.role = @"Conductor";
        }else if ([profileAccount[@"authorities"] containsObject:@"ROLE_PASAJERO"]){
            self.role = @"Pasajero";
        }
        [self setUpProfileView];
        NSLog(@"Account: %@", profileAccount);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary*errorResponse = (NSDictionary*)operation.responseObject;
        NSLog(@"%@",errorResponse);
        if ([errorResponse[@"error"] rangeOfString:@"invalid_token"].location != NSNotFound) {
            NSLog(@"Invalid token");
            [self getNewToken];
        } else {
            NSLog(@"%@",errorResponse[@"error_description"]);
        }
        [hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

-(void)getNewToken{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary*parameters=@{@"client_id": @"Riderapp",
                              @"client_secret": @"mySecretOAuthSecret",
                              @"grant_type":@"refresh_token",
                              @"refresh_token":[self refreshToken]
                              };
    
    [manager.requestSerializer setValue:@"Basic UmlkZXJhcHA6bXlTZWNyZXRPQXV0aFNlY3JldA==" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager POST:@"http://69.46.5.166:8084/rider/oauth/token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [hud hide:YES];
        NSDictionary*temp=(NSDictionary*)responseObject;
        [self setAuthToken:[temp objectForKey:@"access_token"]];
        [self setRefreshToken:[temp objectForKey:@"refresh_token"]];
        NSLog(@"Token: %@", temp);
        [self getAccount];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary*errorResponse = (NSDictionary*)operation.responseObject;
        NSLog(@"%@",errorResponse);
        [hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    }];
}

#pragma mark - Routes

-(void)getRoutes{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Cargando", nil);
    hud.detailsLabelText=@"Hoken";
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.opacity=1.0;
    hud.color=[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[self authToken]] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"Accept"forHTTPHeaderField:@"application/json"];
    [manager GET:@"http://localhost:8080/rider/api/rutas" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [hud hide:YES];
        myRoutes=(NSArray*)responseObject;
        for (int i=0; i<[myRoutes count]; i++) {
            NSLog(@"Routes: %@", myRoutes[i][@"id"]);
        }
        [self.myTableView.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",(NSDictionary*)operation.responseObject);
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [hud hide:YES];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"map"]){
        MapViewController* destinationController = segue.destinationViewController;
        destinationController.firstName = self.firstName;
        destinationController.lastName = self.lastName;
        destinationController.email = self.email;
        destinationController.idUser = self.idUser;
    }
    if([segue.identifier isEqualToString:@"myroute"]){
        MyRoutesViewController* destinationController = segue.destinationViewController;
        destinationController.routeJson = myRoutes[routeSelected][@"json"];
        destinationController.idRoute = myRoutes[routeSelected][@"id"];
    }
}

#pragma mark - Defauls

-(void)setUserAuthentication:(BOOL)authentication{
    [[NSUserDefaults standardUserDefaults] setBool:authentication forKey:@"auth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)userAuthentication{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"auth"];
}

-(void)setAuthToken:(NSString*)token{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"HokenToken" accessGroup:nil];
    [keychainItem setObject:token forKey:(id)kSecAttrAccount];
}

-(NSString*)authToken{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"HokenToken" accessGroup:nil];
    return [keychainItem objectForKey:(id)kSecAttrAccount];
}

-(NSString*)login{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
}

-(void)setRefreshToken:(NSString*)token{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"refresh_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)refreshToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"refresh_token"];
}

@end
