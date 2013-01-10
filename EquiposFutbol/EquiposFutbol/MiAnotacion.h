//
//  MiAnotacion.h
//  Ej1T5
//
//  Created by macbook on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>

@interface MiAnotacion : NSObject <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property(nonatomic,readonly) CLLocationCoordinate2D coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c title:t subtitle:st;
-(NSString *)title;
-(NSString *)subtitle;

@end
