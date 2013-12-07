//
//  HUD.h
//  SpyAR
//
//  Created by Robby Kraft on 11/11/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

//@protocol HUDDelegate <NSObject>
//
//@end

@interface HUD : NSObject

//@property id <HUDDelegate> delegate;
@property float rotation;
@property (nonatomic) GLKVector3 eyeVector;

-(void) setLookAzimuth:(float)a Altitude:(float)b;
-(void) setCelestialFocusAzimuth:(float)a Altitude:(float)b;
-(void) execute;
-(void) updateStarName:(NSString*)string;

@end
