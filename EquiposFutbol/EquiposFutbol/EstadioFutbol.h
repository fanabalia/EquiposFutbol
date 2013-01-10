//
//  EstadioFutbol.h
//  EquiposFutbol
//
//  Created by macbook on 27/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EstadioFutbol : NSObject{
    NSString *nombreEstadio;
    NSString *ciudad;   
    NSNumber *latitud;
    NSNumber *longitud;    
}

@property (nonatomic, copy) NSString *nombreEstadio;
@property (nonatomic, copy) NSString *ciudad;
@property (nonatomic, copy) NSNumber *latitud;
@property (nonatomic, copy) NSNumber *longitud;

+ (id)objetoEstadioFutbol:(NSString*)nombreEstadio ciudad:(NSString*)ciudad latitud:(NSNumber *)latitud longitud:(NSNumber *) longitud;

@end
