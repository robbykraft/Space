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
#import "LoadingStage.h"

@interface Celestial : GLKView

// device
@property (nonatomic) float fieldOfView;  // 60-90 is average
@property (nonatomic) BOOL pinchZoom;
@property (nonatomic) BOOL orientToDevice;
@property (nonatomic) GLKMatrix4 attitudeMatrix;

// celestial groups
@property (nonatomic) Stars *stars;
@property (nonatomic) LoadingStage *loadingStage;

-(void) execute;  // draw screen

@end
