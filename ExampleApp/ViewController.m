//
//  ViewController.m
//  LocationManager
//
//  Created by Hipolito Arias on 25/3/15.
//  Copyright (c) 2015 Hipolito Arias. All rights reserved.
//

#import "ViewController.h"
#import "Annotation.h"

#define cellId @"CellId"

@interface ViewController () <HACLocationManagerDelegate, MKMapViewDelegate> {
    NSArray * section_0;
    NSArray * section_1;
    UIActivityIndicatorView *ai;
    Annotation *userAnnotation;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[HACLocationManager sharedInstance]requestAuthorizationLocation];
    [[HACLocationManager sharedInstance]setPrecision:HighPrecision];
    [[HACLocationManager sharedInstance]setFirstUpdateSeconds:2];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    self.mapView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mapView.layer.shadowOffset = CGSizeMake(4, 10);
    self.mapView.layer.shadowRadius = 5.0;
    self.mapView.layer.shadowOpacity = 0.6;
    self.mapView.layer.masksToBounds = NO;
    
    self.btnUSerLoc.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnUSerLoc.layer.shadowOffset = CGSizeMake(4, 10);
    self.btnUSerLoc.layer.cornerRadius = 4.0;
    self.btnUSerLoc.layer.shadowRadius = 5.0;
    self.btnUSerLoc.layer.shadowOpacity = 0.6;
    self.btnUSerLoc.layer.masksToBounds = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        
        return section_0.count;
    }else if(section ==1){
        
        return section_1.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = section_0[indexPath.row];
            break;
            
        case 1:
            cell.textLabel.text = section_1[indexPath.row];
            break;
    }
    
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 25)];
    label.textColor = [UIColor whiteColor];
    
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    
    NSString *string =@"";
    
    switch (section) {
        case 0:
            string = @"Lat - Lng";
            break;
            
        case 1:
            string = @"Address";
            break;
        default:
            break;
    }
    
    [label setText:string];
    
    [view addSubview:label];
    
    [view setBackgroundColor:[UIColor colorWithRed:0.29 green:0.53 blue:0.91 alpha:1.0]];
    
    return view;
}

# pragma mark - IBActions

- (IBAction)tapUserLocation:(id)sender {
    [self startActivity];
    [self disabledButtons];
    [[HACLocationManager sharedInstance]startUpdatingLocationWithDelegate:self];
}

-(void)mapZoomWithMap:(MKMapView *)map userLocation:(CLLocation *)userLoc{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLoc.coordinate.latitude;
    location.longitude = userLoc.coordinate.longitude;
    region.span = span;
    region.center = location;
    [map setRegion:region animated:YES];
    
    
}

-(void)startActivity{
    
    //Create and add the Activity Indicator to splashView
    ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    ai.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:.9];
    ai.alpha = 1.0;
    ai.center = self.view.center;
    ai.hidesWhenStopped = YES;
    [self.view addSubview:ai];
    [ai startAnimating];
}

# pragma mark - HACLocationManager
-(void)didFinishFirstUpdateLocation:(CLLocation *)location{
    
    
    NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy];
    
    if (annotationsToRemove.count > 0)
        [self.mapView removeAnnotations:annotationsToRemove];
    
    MKCoordinateRegion Bridge = { {0.0, 0.0} , {0.0, 0.0} };
    Bridge.center.latitude = location.coordinate.latitude;
    Bridge.center.longitude = location.coordinate.longitude;
    Bridge.span.longitudeDelta = 0.04f;
    Bridge.span.latitudeDelta = 0.04f;
    
    userAnnotation = [[Annotation alloc] init];
    userAnnotation.title = @"I'm a pin";
    userAnnotation.subtitle = @"Your subtitle";
    userAnnotation.coordinate = Bridge.center;
    
    [self.mapView addAnnotation:userAnnotation];
    
    section_0 = @[[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]];
    
    [self.tableView reloadData];
}



-(void) didUpdatingLocationExactly:(CLLocation *)location{
    [self mapZoomWithMap:self.mapView userLocation:location];
    [userAnnotation setCoordinate:location.coordinate];
}


-(void)didFinishGetAddress:(NSDictionary *)placemark location:(CLLocation *)location{
    
    section_1 = (NSArray *)[placemark valueForKey:@"FormattedAddressLines"];
    [self enableButtons];
    
    section_0 = @[[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]];
    
    
    [self.tableView reloadData];
    [ai stopAnimating];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error Location: %@", [error localizedDescription]);
    [ai stopAnimating];
    [self enableButtons];
}

-(void)didFailGettingAddressWithError:(NSError *)error{
    NSLog(@"Error al coger la dirección\nError: %@", [error localizedDescription]);
    [ai stopAnimating];
    [self enableButtons];
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    
    MyPin.draggable = YES;
    MyPin.animatesDrop=TRUE;
    MyPin.canShowCallout = YES;
    MyPin.highlighted = NO;
    
    return MyPin;
}

-(void)enableButtons{
    self.btnUSerLoc.enabled = YES;
}

-(void)disabledButtons{
    self.btnUSerLoc.enabled = NO;
}

@end
