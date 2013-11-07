//
//  PanoramaView.m
//  Spherical
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "PlanetariumView.h"
#import "Sphere.h"

#define FOV_MAX 155
#define FOV_MIN 1
#define SLICES 48

@interface PlanetariumView (){
    Sphere *sphere;
    Sphere *celestial;
    CGFloat aspectRatio;
    CGFloat zoom;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
    NSInteger logCount;
}
@end

@implementation PlanetariumView

-(id) init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}
-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    return [self initWithFrame:frame];
}
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = 1.0/45.0; // this will exhaust the battery!
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
        [pinchGesture setEnabled:NO];
        [self addGestureRecognizer:pinchGesture];
        [self initGL];
    }
    return self;
}

-(void)initGL{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    
    _timeSpeed = .01;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        _fieldOfView = 75;
    else
        _fieldOfView = 60;
    
    aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        aspectRatio = 1/aspectRatio;
    
    sphere = [[Sphere alloc] init:SLICES slices:SLICES radius:10.0 squash:1.0 textureFile:nil];
    celestial = [[Sphere alloc] init:SLICES slices:SLICES radius:20.0 squash:1.0 textureFile:@"Tycho_2048_city_reflection.png"];
    
    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    glMatrixMode(GL_PROJECTION);    // the frustum affects the projection matrix
    glLoadIdentity();               // not the model matrix
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(_fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_BLEND);
    glLoadIdentity();
}

-(void) updateFieldOfView{
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    float zNear = 0.1;
    float zFar = 1000;
    GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(_fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_DEPTH_TEST);
    glPopMatrix();
}

-(void) setTexture:(NSString*)fileName{
    [sphere swapTexture:fileName];
}

-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    [self updateFieldOfView];
}

-(void) setPinchZoom:(BOOL)pinchZoom{
    _pinchZoom = pinchZoom;
    if(_pinchZoom)
        [pinchGesture setEnabled:YES];
    else
        [pinchGesture setEnabled:NO];
}

-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    if([sender state] == 1)
        zoom = _fieldOfView;
    if([sender state] == 2){
        CGFloat newFOV = zoom / [sender scale];
        if(newFOV < FOV_MIN) newFOV = FOV_MIN;
        else if(newFOV > FOV_MAX) newFOV = FOV_MAX;
        [self setFieldOfView:newFOV];
    }
}

-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(_orientToDevice){
        if(motionManager.isDeviceMotionAvailable){
            [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                _attitudeMatrix =
                GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                               a.m13, a.m23, a.m33, 0.0f,
                               -a.m12,-a.m22,-a.m32,0.0f,
                               0.0f , 0.0f , 0.0f , 1.0f);
                
//                GLKMatrix4 seasonDirection = GLKMatrix4MakeRotation(M_PI, 0, 1, 0);
//                _attitudeMatrix = GLKMatrix4Multiply(_attitudeMatrix, seasonDirection);
//                GLKMatrix4 earthTilt = GLKMatrix4MakeRotation(M_PI/180.0*23.45, 1, 0, 0);
//                _attitudeMatrix = GLKMatrix4Multiply(_attitudeMatrix, earthTilt);
//                GLKMatrix4 daytime = GLKMatrix4MakeRotation(2*M_PI/24.0*_timeAtGMT, 0, 1, 0);
//                _attitudeMatrix = GLKMatrix4Multiply(_attitudeMatrix, daytime);
//                GLKMatrix4 latitude = GLKMatrix4MakeRotation(M_PI/180.0*45.0, 0, 0, 1);
//                _attitudeMatrix = GLKMatrix4Multiply(_attitudeMatrix, latitude);
            
//                CMCalibratedMagneticField mag = deviceMotion.magneticField;
//                logCount++;
//                if(logCount%15 == 0){
//                    NSLog(@"(%d) (%.3f, %.3f, %.3f)",mag.accuracy,mag.field.x, mag.field.y, mag.field.z);
//                }
            }];
        }
    }
    else {
        [motionManager stopDeviceMotionUpdates];
    }
}

-(void)execute{
    static float daytime;
    daytime += _timeSpeed;
    if(daytime >= 24) daytime = 0;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    
    glMatrixMode(GL_MODELVIEW);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    glEnable(GL_BLEND);
    
    if(_celestialSphere){
        glPushMatrix();
        glMultMatrixf(_attitudeMatrix.m);
        // made-up figures to fake a spinning planet
        GLKMatrix4 latitude = GLKMatrix4MakeRotation(M_PI/180.0*45.0, 0, 0, 1);
        glMultMatrixf(latitude.m);
        GLKMatrix4 earthTilt = GLKMatrix4MakeRotation(M_PI/180.0*23.45, 1, 0, 0);
        glMultMatrixf(earthTilt.m);
        GLKMatrix4 day = GLKMatrix4MakeRotation(2*M_PI/24.0*daytime, 0, 1, 0);
        glMultMatrixf(day.m);
        [self executeSphere:celestial];
        glPopMatrix();
    }
    
    glPushMatrix();
    glMultMatrixf(_attitudeMatrix.m);
    [self executeSphere:sphere];
    glPopMatrix();
    
}

-(void)executeSphere:(Sphere *)s{
    GLfloat posX, posY, posZ;
    glPushMatrix();
    [s getPositionX:&posX Y:&posY Z:&posZ];
    glTranslatef(posX, posY, posZ);
    [s execute];
    glPopMatrix();
}

@end