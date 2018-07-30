//
//  ViewController.h
//  Sunrise
//
//  Created by Dmitry Reshetnik on 7/27/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@interface ViewController : UIViewController <GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *chosenLocation;
@property (weak, nonatomic) IBOutlet UILabel *currentLocation;
@property (weak, nonatomic) IBOutlet UILabel *sunriseTime;
@property (weak, nonatomic) IBOutlet UILabel *sunsetTime;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;


@end

