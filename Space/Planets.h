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

@property (nonatomic) NSArray *distantPlanets;
@property id <PlanetsDelegate> delegate;

-(void)execute;

@end