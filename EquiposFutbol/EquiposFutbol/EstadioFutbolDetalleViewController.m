//
//  EstadioFutbolDetalleViewController.m
//  EquiposFutbol
//
//  Created by macbook on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EstadioFutbolDetalleViewController.h"

@implementation EstadioFutbolDetalleViewController

@synthesize nombreEstadio,ciudad,estadioFutbol,mapa;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[MiAnotacion class]]){        
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView)
        {
            pinView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.enabled = YES;
            pinView.canShowCallout = YES;
            pinView.image=[UIImage imageNamed:@"pin.png"];
            
            
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
        
    }
    
    
    
    return nil;
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    nombreEstadio.text=estadioFutbol.nombreEstadio;
    ciudad.text=estadioFutbol.ciudad;
    
    CLLocationCoordinate2D coord;
    coord.latitude=[estadioFutbol.latitud doubleValue];
    coord.longitude=[estadioFutbol.longitud doubleValue];
    MiAnotacion * anotacion=[[MiAnotacion alloc] initWithCoordinate:coord title:estadioFutbol.nombreEstadio subtitle:estadioFutbol.ciudad];
    
    
    [mapa addAnnotation:anotacion];  
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = coord.latitude;
    zoomLocation.longitude= coord.longitude;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*1609.344, 0.5*1609.344);
    // 3
    MKCoordinateRegion adjustedRegion = [mapa regionThatFits:viewRegion];                
    // 4
    [mapa setRegion:adjustedRegion animated:YES];    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
