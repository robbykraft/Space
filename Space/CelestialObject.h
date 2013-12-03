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
@property float *position;  // either (X,Y,Z) (euclidian) or (AZ,ALT,DIST) (spherical)
@property BOOL euclidian;  //  for position, whether (X,Y,Z) or not

@property float azimuth;
@property float altitude;
@property float distance;

-(id)initWithAzimuth:(float)a Altitude:(float)b Distance:(float)c;
-(id)initWithX:(float)a y:(float)b z:(float)c;

@end