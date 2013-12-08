//
//  Stars.h
//  Space
//
//  Created by Robby Kraft on 11/10/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "CelestialObject.h"
#import "CelestialGroup.h"

@protocol StarsDelegate <NSObject>

@optional
-(void)starsDidLoad;
@end

@interface Stars : CelestialGroup

@property (nonatomic) NSArray *starCatalog;
@property id <StarsDelegate> delegate;
-(void)execute;
-(void)setLookAzimuth:(float)a Altitude:(float)b;

-(id)nearestStarToAzimuth:(float)a Altitude:(float)b;

@end