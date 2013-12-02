//
//  CelestialObject.h
//  Space
//
//  Created by Robby Kraft on 11/30/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

@interface CelestialObject : NSObject

@property (nonatomic, strong) NSString *name;

//coordinates
@property float *sphericalCoordinates;
@property float *euclidianCoordinates;
@property float *position;  // pointer to one of the two above
@property BOOL spherical;

-(id)initWithAzimuth:(float)a Altitude:(float)b Distance:(float)c;
-(id)initWithX:(float)a y:(float)b z:(float)c;

@end