//
//  Planets.h
//  Space
//
//  Created by Robby Kraft on 11/12/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "CelestialGroup.h"

@protocol PlanetsDelegate <NSObject>

@optional
-(void)planetDidLoad;
@end

@interface Planets : CelestialGroup

@property id <PlanetsDelegate> delegate;
@property (nonatomic) float time;

-(id) initWithTime:(float)J2000Time;
-(void)calculate;  //calculate positions based on time
-(void)execute;

@end