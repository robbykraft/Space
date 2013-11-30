//
//  CelestialObject.m
//  Space
//
//  Created by Robby Kraft on 11/30/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "CelestialObject.h"

@implementation CelestialObject

-(id)initWithAzimuth:(float)a Altitude:(float)b Distance:(float)c{
    self = [self init];
    if(self){
        _position = _sphericalCoordinates;
        _position[AZIMUTH] = a;
        _position[ALTITUDE] = b;
        _position[DISTANCE] = c;
        _spherical = YES;
    }
    return self;
}

-(id)initWithX:(float)a y:(float)b z:(float)c{
    self = [self init];
    if(self){
        _position = _euclidianCoordinates;
        _position[X] = a;
        _position[Y] = b;
        _position[Z] = c;
        _spherical = NO;
    }
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        _sphericalCoordinates = malloc(sizeof(float)*3);
        _sphericalCoordinates[AZIMUTH] = _sphericalCoordinates[ALTITUDE] = _sphericalCoordinates[DISTANCE] = 0.0;
        _euclidianCoordinates = malloc(sizeof(float)*3);
        _euclidianCoordinates[X] = _euclidianCoordinates[Y] = _euclidianCoordinates[Z] = 0.0;
    }
    return self;
}

-(void)recalculate{
}
@end
