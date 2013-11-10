//
//  PanoramaView.h
//  Space
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol LoadingDelegate <NSObject>

@optional
-(void)starsDidLoad;
@end

@interface Celestial : GLKView

@property (nonatomic) float fieldOfView;  // 60-90 is average
@property (nonatomic) BOOL pinchZoom;
@property (nonatomic) BOOL orientToDevice;
@property (nonatomic) GLKMatrix4 attitudeMatrix;
@property BOOL celestialSphere;  // bonus: rotating stars
@property (nonatomic,strong) NSArray *stars;
@property id <LoadingDelegate> loadingDelegate;
@property float time;

-(void) execute;  // draw screen
-(void) setTexture:(NSString*)fileName;

@end
