//
//  MiAnotacion.m
//  Ej1T5
//
//  Created by macbook on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MiAnotacion.h"

@implementation MiAnotacion

@synthesize coordinate;

-(NSString *)title
{
    return title;
}

-(NSString *)subtitle
{
    return subtitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c title:(id)t subtitle:(id)st
{
    coordinate=c;
    title=t;
    subtitle=st;
    return self;
}

@end
