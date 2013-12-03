//
//  CelestialObject.m
//  Space
//
//  Created by Robby Kraft on 11/30/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "CelestialObject.h"

@interface CelestialObject (){
    float *_sphericalCoordinates;
    float *_euclidianCoordinates;
}
@end

@implementation CelestialObject

-(id)initWithAzimuth:(float)a Altitude:(float)b Distance:(float)c{
    self = [self init];
    if(self){
        _sphericalCoordinates = malloc(sizeof(float)*3);
        _sphericalCoordinates[AZIMUTH] = a;
        _sphericalCoordinates[ALTITUDE] = b;
        _sphericalCoordinates[DISTANCE] = c;
        _azimuth = _sphericalCoordinates[AZIMUTH];
        _altitude = _sphericalCoordinates[ALTITUDE];
        _distance = _sphericalCoordinates[DISTANCE];
        _position = _sphericalCoordinates;
        _euclidian = NO;
    }
    return self;
}

-(id)initWithX:(float)a y:(float)b z:(float)c{
    self = [self init];
    if(self){
        _euclidianCoordinates = malloc(sizeof(float)*3);
        _euclidianCoordinates[X] = a;
        _euclidianCoordinates[Y] = b;
        _euclidianCoordinates[Z] = c;
        _position = _euclidianCoordinates;
        _euclidian = YES;
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
