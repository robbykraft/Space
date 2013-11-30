//
//  PanoramaView.h
//  Space
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Stars.h"
#import "Planets.h"
#import "LoadingStage.h"
#import "HUD.h"

@interface Celestial : GLKView <StarsDelegate, PlanetsDelegate>

// device
@property (nonatomic) float fieldOfView;  // 60-90 is average
@property (nonatomic) BOOL pinchZoom;
@property (nonatomic) BOOL orientToDevice;
@property (nonatomic) GLKMatrix4 attitudeMatrix;

// celestial groups
@property (nonatomic) Stars *stars;
@property (nonatomic) Planets *planets;
@property (nonatomic) LoadingStage *loadingStage;
@property (nonatomic) HUD *hud;

-(void) execute;  // draw screen

@end
