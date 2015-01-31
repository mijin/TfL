//
//  ViewController.m
//  TfL
//
//  Created by Mijin Cho on 31/01/2015.
//  Copyright (c) 2015 Mijin Cho. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "Requests.h"
#import "BusAnnotation.h"
#import "TubeAnnotation.h"
#import "TramAnnotation.h"

dispatch_queue_t queue;


@interface ViewController ()
@property (readwrite) float longitude;
@property (readwrite) float latitude;
@end

@implementation ViewController

-(void)startLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    #ifdef __IPHONE_8_0
        if(IS_OS_8_OR_LATER) {
            
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
        }
    #endif
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    queue = dispatch_queue_create("com.test.queue",nil);
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.mapView];
    self.mapView.delegate =self;
    
    [self startLocationManager];
    
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    self.title = NSLocalizedString(@"TFL", @"TFL");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}



- (void)getPublicTransportation
{
    
    dispatch_async(queue, ^{
        
        NSMutableArray* places = [[Requests getPlace:self.latitude lon:self.longitude radius:500 categories:@"stop"] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [places enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary* item = obj;
                NSString* modes = nil;
                
                @try {
                    if([[item objectForKey:@"stopType"] isEqualToString:@"NaptanRailEntrance" ])
                    {
                        modes  = @"NaptanRailEntrance";
                    }
                    else
                    {
                        modes  = [[item objectForKey:@"modes"]
                                  objectAtIndex:0];
                    }
                    
                    
                    CLLocationCoordinate2D a = CLLocationCoordinate2DMake(   [[item objectForKey:@"lat"] floatValue],
                                                                          [[item objectForKey:@"lon"] floatValue]);
                    
                    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:a addressDictionary:nil];
                    
                    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                    mapItem.name = [item objectForKey:@"stopLetter"];
                    
                    
                    if([modes isEqualToString:@"bus"])
                    {
                        BusAnnotation *annotation = [[BusAnnotation alloc] init];
                        annotation.coordinate = mapItem.placemark.location.coordinate;
                        annotation.subTitle = @" ";
                        for (NSString * str in  [[[item objectForKey:@"lineModeGroups"] objectAtIndex:0] objectForKey:@"lineIdentifier"]) {
                            annotation.subTitle = [NSString stringWithFormat:@"%@,%@",annotation.subTitle,str];
                        }
                        annotation.subTitle  = [annotation.subTitle stringByReplacingOccurrencesOfString:@" ," withString:@""];
                        
                        //[NSString stringWithFormat:@"%.1f miles",[[item objectForKey:@"distance"] floatValue]  * 0.01];
                        annotation.title = [item objectForKey:@"commonName"];
                        if([item objectForKey:@"stopLetter"])
                            annotation.title = [NSString stringWithFormat:@"%@ %@",[item objectForKey:@"stopLetter"],
                                                [item objectForKey:@"commonName"]];
                        annotation.url = mapItem.url;
                        
                        [[Global sharedInstance].busArray addObject:annotation];
                        
                    }
                    else if([modes isEqualToString:@"tube"] ||
                            [modes isEqualToString:@"NaptanRailEntrance"]
                            /*
                             ||[modes isEqualToString:@"overground"]||
                             [modes isEqualToString:@"dlr"]*/)
                    {
                        TubeAnnotation *annotation = [[TubeAnnotation alloc] init];
                        annotation.coordinate = mapItem.placemark.location.coordinate;
                        annotation.title = [item objectForKey:@"commonName"];
                        annotation.url = mapItem.url;
                        [[Global sharedInstance].tubeArray addObject:annotation];
                        
                    }
                    else if([modes isEqualToString:@"tram"])
                    {
                        TramAnnotation *annotation = [[TramAnnotation alloc] init];
                        annotation.coordinate = mapItem.placemark.location.coordinate;
                        annotation.title = [item objectForKey:@"commonName"];
                        annotation.url = mapItem.url;
                        [[Global sharedInstance].tramArray addObject:annotation];
                    }
                    
                }
                @catch (NSException *exception) {
                    
                }
                
                
            }];
            
            /*Display annotations*/
            [self.mapView addAnnotations:[Global sharedInstance].tubeArray];
            [self.mapView addAnnotations:[Global sharedInstance].busArray];
            [self.mapView addAnnotations:[Global sharedInstance].tramArray];
            
            
        });
    });
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we illustrate how to detect which annotation type was clicked on for its callout
    //id <MKAnnotation> annotation = [view annotation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *returnedAnnotationView = nil;
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {
        if ([annotation isKindOfClass:[BusAnnotation class]]) // for Golden Gate Bridge
        {
            returnedAnnotationView = [BusAnnotation createViewAnnotationForMapView:self.mapView annotation:annotation];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            ((MKPinAnnotationView *)returnedAnnotationView).rightCalloutAccessoryView = rightButton;
        }
    }
    
    static NSString *AnnotationIdentifier = @"Me";
    if ([annotation isKindOfClass:[TubeAnnotation class]])
        AnnotationIdentifier = @"Tube";
    else if ([annotation isKindOfClass:[TramAnnotation class]])
        AnnotationIdentifier = @"Tram";
    else if ([annotation isKindOfClass:[BusAnnotation class]])
        AnnotationIdentifier = @"Bus";
    
    MKAnnotationView *flagAnnotationView =
    [self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (flagAnnotationView == nil)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:AnnotationIdentifier];
        annotationView.canShowCallout = YES;
        UIImage *flagImage =nil;
        if ([annotation isKindOfClass:[TubeAnnotation class]])
            flagImage =  [UIImage imageNamed:@"tube"];
        else if ([annotation isKindOfClass:[TramAnnotation class]])
            flagImage = [UIImage imageNamed:@"tram"];
        else if ([annotation isKindOfClass:[BusAnnotation class]])
            flagImage = [UIImage imageNamed:@"bus"];
        else if ([annotation isKindOfClass:[MKUserLocation class]])
        {
            flagImage = [UIImage imageNamed:@"location"];
        }
        annotationView.image = flagImage;
        annotationView.opaque = NO;
        
        
        
        // offset the flag annotation so that the flag pole rests on the map coordinate
        annotationView.centerOffset = CGPointMake( annotationView.centerOffset.x + annotationView.image.size.width/2, annotationView.centerOffset.y - annotationView.image.size.height/2 );
        
        return annotationView;
    }
    else
    {
        flagAnnotationView.annotation = annotation;
    }
    return flagAnnotationView;
    
    return nil;
    
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation");
}

#pragma mark - locationManager
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:  (CLAuthorizationStatus)status
{
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [self.mapView setRegion:region animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitude = newLocation.coordinate.latitude;
    self.longitude = newLocation.coordinate.longitude;

    //NSLog(@"newLocation %@",newLocation);
    
    
    self.mapView.showsUserLocation = YES;
    
    [self getPublicTransportation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([error code] != kCLErrorLocationUnknown) {
        //NSLocalizedString(@"Error", @"Error")
        
    }
}
@end
