//
//  EstadioFutbol.m
//  EquiposFutbol
//
//  Created by macbook on 27/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EstadioFutbol.h"

@implementation EstadioFutbol

@synthesize nombreEstadio;
@synthesize ciudad;
@synthesize latitud;
@synthesize longitud;

+ (id)objetoEstadioFutbol:(NSString*)nombreEstadio ciudad:(NSString*)ciudad latitud:(NSNumber *)latitud longitud:(NSNumber *) longitud    
{
    EstadioFutbol *newEstadioFutbol = [[self alloc] init];
    newEstadioFutbol.nombreEstadio = nombreEstadio;
    newEstadioFutbol.ciudad = ciudad;
    newEstadioFutbol.latitud = latitud;
    newEstadioFutbol.longitud = longitud;
    return newEstadioFutbol;
}

@end
