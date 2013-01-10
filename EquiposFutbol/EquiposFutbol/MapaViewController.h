//
//  MapaViewController.h
//  EquiposFutbol
//
//  Created by macbook on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "SBJSON.h"
#import "EstadioFutbol.h"
#import "MiAnotacion.h"
#import "CoreDataManager.h"

@interface MapaViewController : UIViewController<MKMapViewDelegate>{
    NSMutableArray *estadiosFutbolArray;
    IBOutlet MKMapView *mapa;
}

@property (strong,nonatomic) NSMutableArray *estadiosFutbolArray;
@property(nonatomic,strong) IBOutlet MKMapView *mapa;

@end
