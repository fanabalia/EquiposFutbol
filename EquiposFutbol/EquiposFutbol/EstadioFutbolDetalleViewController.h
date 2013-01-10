//
//  EstadioFutbolDetalleViewController.h
//  EquiposFutbol
//
//  Created by macbook on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "EstadioFutbol.h"
#import "MiAnotacion.h"

@interface EstadioFutbolDetalleViewController : UIViewController<MKMapViewDelegate>{
    EstadioFutbol *estadioFutbol;
    IBOutlet UILabel *nombreEstadio;
    IBOutlet UILabel *ciudad;
    IBOutlet MKMapView *mapa;
}

@property(nonatomic,strong) EstadioFutbol *estadioFutbol;
@property(nonatomic,strong) IBOutlet UILabel *nombreEstadio;
@property(nonatomic,strong) IBOutlet UILabel *ciudad;
@property(nonatomic,strong) IBOutlet MKMapView *mapa;

@end
