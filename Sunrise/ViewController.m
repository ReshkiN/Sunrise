//
//  ViewController.m
//  Sunrise
//
//  Created by Dmitry Reshetnik on 7/27/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    // Code to check if the app can respond to the new selector found in iOS 8. If so, request it.
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        //[self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.location = [[CLLocation alloc] init];
    [self.locationManager startUpdatingLocation];
    
    _placesClient = [GMSPlacesClient sharedClient];
    [self getCurrentPlace];
}

// Gets the user location.
- (void)getCurrentPlace {
    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        self.currentLocation.text = @"No current place";
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                // GET request to https://api.sunrise-sunset.org/json. for getting sunset and sunrise information from API for a given location
                NSError *error;
                NSString *url_string = [NSString stringWithFormat: @"https://api.sunrise-sunset.org/json?lat=%f&lng=%f", place.coordinate.latitude, place.coordinate.longitude];
                NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSArray *sunrise = [json valueForKeyPath:@"results.sunrise"];
                NSArray *sunset = [json valueForKeyPath:@"results.sunset"];
                
                for (GMSAddressComponent *component in place.addressComponents) {
                    if ([component.type  isEqual: @"locality"]) {
                        self.currentLocation.text = component.name;
                        self.chosenLocation.text = component.name;
                    }
                }
                self.sunriseTime.text = [NSString stringWithFormat:@"%@", sunrise];
                self.sunsetTime.text = [NSString stringWithFormat:@"%@", sunset];
            }
        }
    }];
}

// Gets the user location when the button is pressed.
- (IBAction)getCurrentPlaceButton:(UIButton *)sender {
    [self getCurrentPlace];
}

// Present the autocomplete view controller when the button is pressed.
- (IBAction)onLaunchClicked:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://api.sunrise-sunset.org/json?lat=%f&lng=%f", place.coordinate.latitude, place.coordinate.longitude];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray *sunrise = [json valueForKeyPath:@"results.sunrise"];
    NSArray *sunset = [json valueForKeyPath:@"results.sunset"];
    self.chosenLocation.text = place.name;
    self.sunriseTime.text = [NSString stringWithFormat:@"%@", sunrise];
    self.sunsetTime.text = [NSString stringWithFormat:@"%@", sunset];
}

// Handle the error.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
