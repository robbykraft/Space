//
//  CelestialObject.h
//  Space
//
//  Created by Robby Kraft on 11/30/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

@interface CelestialObject : NSObject

@property float *sphericalCoordinates;
@property float *euclidianCoordinates;

@property float *position;
@property BOOL spherical;

-(id)initWithAzimuth:(float)a Altitude:(float)b Distance:(float)c;
-(id)initWithX:(float)a y:(float)b z:(float)c;

@end