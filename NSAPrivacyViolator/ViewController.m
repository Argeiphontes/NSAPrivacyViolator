//
//  ViewController.m
//  NSAPrivacyViolator
//
//  Created by Christopher on 10/15/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property CLLocationManager *myLocationManager;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

// step one: hook up textView & buttons
// step two: link & import core location framework; hook up core locationmanager delegate; add CLLocationManager property; set up methods to update location and request when in use authorization; add NSLocationWhenInUseUsageDescription to plist; set this VC as delegate of myLocationManager.
//step three: add didUpdateLocations (which is called through delegate method); this method measures accuracy within 1,000 meters; calls reverseGeocode method on self and calls stopUpdatingLocation.
//step four: add code to reverseGeocode;
//step five:  import mapKit; add code to method find jail near

@implementation ViewController
- (IBAction)startViolatingPrivacy:(UIButton *)sender {
    [self.myLocationManager startUpdatingLocation];
    self.textView.text = @"Locating You...";
    NSLog(@"Oh oh");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc]init];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;

    // Do any additional setup after loading the view, typically from a nib.
}

// part of step two: just to log out error
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"I failed: %@:", error);

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.textView.text = @"Location Found. Reverse Geocoding...";
            [self reverseGeocode: location];
            NSLog(@"The Location is %@", location);
            [self.myLocationManager stopUpdatingLocation];
            break;

        }
    }
}

// this is step four.
-(void) reverseGeocode: (CLLocation *) location
{
    CLGeocoder *geocoder = [CLGeocoder new];

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@ /n %@",
                             placemark.subThoroughfare,
                             placemark.thoroughfare,
                             placemark.locality];
        self.textView.text = [NSString stringWithFormat:@"Found you: %@", address];
        [self findJailNear:placemark.location];
    }];
}

// this is step five.
-(void) findJailNear: (CLLocation *) location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"prison";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItem = mapItems.firstObject;
        self.textView.text = [NSString stringWithFormat:@"You should go to %@", mapItem.name];
    }];
}

@end
