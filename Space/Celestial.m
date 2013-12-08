//
//  PanoramaView.m
//  Space
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "Celestial.h"
#import "Sphere.h"

#define Z_NEAR 0.001f
#define Z_FAR 10000.0f
#define FOV_MAX 155
#define FOV_MIN 1

@interface Celestial (){
    float _aspectRatio;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
    GLfloat *position;
    NSTimer *travelTimer;
    GLKVector3 _eyeVector;
    GLKVector3 travelVector;
    unsigned int travelIncrements;
    
    float *celestialFocus;
    GLfloat lookAzimuth;
    GLfloat lookAltitude;
    
    GLKMatrix4 planet, ecliptic, galactic;
    float julianDate;
    GLKTextureInfo *maskTexture;
    GLKTextureInfo *jupiterTexture;
    float speed;
    
    NSString *currentFocusName;
//    Sphere *earth;
}

-(void) initDevice;    // boot hardware
-(void) initGL;        // begin openGL
-(void) execute;       // draw screen
-(void) pinchHandler:(UIPinchGestureRecognizer*)sender;

@end

@implementation Celestial

-(id) init{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}
-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    return [self initWithFrame:frame];
}
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDevice];
        [self initGL];
        
        julianDate = .13937029431;
        
        _loadingStage = [[LoadingStage alloc] init];
        
        _stars = [[Stars alloc] init];
        [_stars setDelegate:self];
        
        _planets = [[Planets alloc] init];
        [_planets setDelegate:self];
        [_planets setTime:julianDate];
        [_planets calculate];
        
        _hud = [[HUD alloc] init];
        
        ecliptic = GLKMatrix4MakeRotation(23.4/180.0*M_PI, 1, 0, 0);
        
        celestialFocus = malloc(sizeof(float)*2);
        celestialFocus[AZIMUTH] = celestialFocus[ALTITUDE] = 0.0f;
        
//        earth = [[Sphere alloc] init:24 slices:24 radius:7.0 squash:1.0 textureFile:@"equirectangular-planetarium-lines.png"];

//        [NSTimer scheduledTimerWithTimeInterval:1.0/30. target:self selector:@selector(incrementTime) userInfo:Nil repeats:YES];
    }
    return self;
}

-(void)incrementTime{
    julianDate += .00001;  // .0000001;
    [_planets setTime:julianDate];
    [_planets calculate];
}

-(void) initDevice{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.0/45.0;
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [pinchGesture setEnabled:NO];
    [self addGestureRecognizer:pinchGesture];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        _fieldOfView = 75;
    else
        _fieldOfView = 60;
    _aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        _aspectRatio = 1/_aspectRatio;
    position = malloc(sizeof(GLfloat)*3);
    position[0] = position[1] = position[2] = 0.0f;
    speed = 0.001;
}

-(void)initGL{
    // make sure to initDevice first
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    // init lighting
    glShadeModel(GL_SMOOTH);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
    glEnable(GL_LIGHTING);
    glViewport(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    [self setFieldOfView:_fieldOfView];
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glLoadIdentity();
    maskTexture = [self loadTexture:@"mask.png"];
    jupiterTexture = [self loadTexture:@"Jupiter.png"];
}

-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = Z_NEAR * tanf(GLKMathDegreesToRadians(_fieldOfView) / 2.0);
    glFrustumf(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    glMatrixMode(GL_MODELVIEW);
}

-(void) update{
    static int clock = 0;
    clock++;

    [_stars setLookAzimuth:lookAzimuth Altitude:lookAltitude];
    [_hud setEyeVector:_eyeVector];

    if(clock % 30 == 0){
        CelestialObject *star = [_stars nearestStarToAzimuth:lookAzimuth Altitude:lookAltitude];
        celestialFocus[AZIMUTH] = [star azimuth];
        celestialFocus[ALTITUDE] = [star altitude];
        if(![currentFocusName isEqualToString:[star name]]){
            currentFocusName = [star name];
            [_hud updateStarName:currentFocusName];
        }
    }

}

-(void)execute{
    static const GLfloat octVertices[] = {
        1.0f, 1.0f, 0.0f,
        1.0f, .7071f, .7071f,
        1.0f, 0.0f, 1.0f,
        1.0f, -.7071f, .7071f,
        1.0f, -1.0f, 0.0f,
        1.0f, -.7071f, -.7071f,
        1.0f, 0.0f, -1.0f,
        1.0f, .7071f, -.7071f
    };

    glMatrixMode(GL_MODELVIEW);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat white[] = {1.0,1.0,1.0,1.0};

    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
    
    if(_loadingStage != nil){
        glPushMatrix();
            glMultMatrixf(_attitudeMatrix.m);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glEnable(GL_TEXTURE_2D);
            [_loadingStage execute];
            glEnableClientState(GL_VERTEX_ARRAY);
    
        glPopMatrix();
    }
    else{
        glPushMatrix();
            glMultMatrixf(_attitudeMatrix.m);
        
        // Right Ascention 0° LINE
//        static const GLfloat RA0LineVertices[] = {0.0,-1.0,0.0, 1.0,-1.0,0.0};
//        glPushMatrix();
//            glVertexPointer(3, GL_FLOAT, 0, RA0LineVertices);
//            glDrawArrays(GL_LINE_LOOP, 0, 2);
//        glPopMatrix();


        // HUD target
      
            glDisable(GL_BLEND);
            glDisable(GL_TEXTURE_2D);
            glEnableClientState(GL_VERTEX_ARRAY);

            glPushMatrix();
                glLineWidth(1.0);
                GLKMatrix4 ra = GLKMatrix4MakeRotation(celestialFocus[AZIMUTH], 0.0, 1.0, 0.0);
                glMultMatrixf(ra.m);
                GLKMatrix4 dec = GLKMatrix4MakeRotation(celestialFocus[ALTITUDE], 0.0, 0.0, 1.0);
                glMultMatrixf(dec.m);
                //glTranslatef(1.0, 0.0, 0.0);
                glColor4f(1.0, 1.0, 1.0, 1.0);
                glScalef(1., .01, .01);
                glVertexPointer(3, GL_FLOAT, 0, octVertices);
                glDrawArrays(GL_LINE_LOOP, 0, 8);
            glPopMatrix();
            glDisableClientState(GL_VERTEX_ARRAY);
        
            glPushMatrix();
                [_stars execute];
            glPopMatrix();
        
            glPushMatrix();
                glMultMatrixf(ecliptic.m);   // align ecliptic plane  23.4 degrees
                glTranslatef(_planets.earthPosition[X], _planets.earthPosition[Z], _planets.earthPosition[Y]);
                [_planets execute];
            glPopMatrix();
        
        glPopMatrix();
        
        [_hud execute];
        
        [self update];
    }
}

-(GLKTextureInfo *) loadTexture:(NSString *) filename
{
    NSError *error;
    GLKTextureInfo *info;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:NULL];
    info=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    glBindTexture(GL_TEXTURE_2D, info.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    return info;
}
//
// space exploration
//   translation in space
//
-(void) departingTrip{
    position[0]+= travelVector.x*speed;
    position[1]+= travelVector.y*speed;
    position[2]+= travelVector.z*speed;
    travelIncrements++;
}

-(void) returnTrip{
    position[0]-= travelVector.x*speed;
    position[1]-= travelVector.y*speed;
    position[2]-= travelVector.z*speed;
    travelIncrements--;
    if (travelIncrements <= 0) {
        position[0] = position[1] = position[2] = 0.0;
        [travelTimer invalidate];
        travelTimer = nil;
    }
}

#pragma mark- INTERACTION

-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    static float zoom;
    if([sender state] == 1)
        zoom = _fieldOfView;
    if([sender state] == 2){
        CGFloat newFOV = zoom / [sender scale];
        if(newFOV < FOV_MIN) newFOV = FOV_MIN;
        else if(newFOV > FOV_MAX) newFOV = FOV_MAX;
        [self setFieldOfView:newFOV];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(travelTimer == nil && !travelIncrements){
        travelIncrements = 0;
        travelVector = _eyeVector;
        travelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/45 target:self selector:@selector(departingTrip) userInfo:nil repeats:YES];
    }
    if(travelIncrements){
        [travelTimer invalidate];
        travelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/45 target:self selector:@selector(departingTrip) userInfo:nil repeats:YES];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [travelTimer invalidate];
    travelTimer = nil;
    travelIncrements = 0;
    //    travelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/45 target:self selector:@selector(returnTrip) userInfo:nil repeats:YES];
}

#pragma mark- SETTERS

-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(_orientToDevice){
        if(motionManager.isDeviceMotionAvailable){
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                _attitudeMatrix = GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                                                 a.m13, a.m23, a.m33, 0.0f,
                                                 -a.m12,-a.m22,-a.m32,0.0f,
                                                 0.0f , 0.0f , 0.0f , 1.0f);
                _eyeVector = GLKVector3Make(-_attitudeMatrix.m02,
                                            -_attitudeMatrix.m12,
                                            -_attitudeMatrix.m22);
                lookAzimuth = atan2f(-_eyeVector.z, _eyeVector.x);
                lookAltitude = asinf(_eyeVector.y);
            }];
        }
    }
    else {
        [motionManager stopDeviceMotionUpdates];
    }
}

-(void) setPinchZoom:(BOOL)pinchZoom{
    _pinchZoom = pinchZoom;
    if(_pinchZoom)
        [pinchGesture setEnabled:YES];
    else
        [pinchGesture setEnabled:NO];
}

#pragma mark- DELEGATES

-(void) starsDidLoad{
    NSLog(@"Stars Did Load");
    _loadingStage = nil;
}

@end