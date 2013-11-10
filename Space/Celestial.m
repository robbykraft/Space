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
#import "LoadingStage.h"

#define FOV_MAX 155
#define FOV_MIN 1
#define SLICES 48

@interface Celestial (){
    Sphere *sphere;
    Sphere *celestial;
    LoadingStage *loadingStage;
    CGFloat aspectRatio;
    CGFloat zoom;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
    GLKTextureInfo *buildingTexture;
    GLfloat *RAAndDec;
}
@end

@implementation Celestial

@synthesize loadingDelegate;

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
        motionManager.deviceMotionUpdateInterval = 1.0/45.0;
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
        [pinchGesture setEnabled:NO];
        [self addGestureRecognizer:pinchGesture];
        loadingStage = [[LoadingStage alloc] init];
        [self initGL];
        _time = 0;
    }
    return self;
}

-(void)initGL{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        _fieldOfView = 75;
    else
        _fieldOfView = 60;
    
    aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
    if([UIApplication sharedApplication].statusBarOrientation > 2)
        aspectRatio = 1/aspectRatio;
    
    sphere = [[Sphere alloc] init:SLICES slices:SLICES radius:20.0 squash:1.0 textureFile:nil];
    celestial = [[Sphere alloc] init:SLICES slices:SLICES radius:30.0 squash:1.0 textureFile:@"Hipparcos_2048_B&W_reflection.png"];//@"Tycho_2048_city_reflection.png"];
    
    buildingTexture = [self loadTexture:@"buildingTheUniverse.png"];
    
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
    glEnable(GL_BLEND);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

-(void) updateFieldOfView{
    float zNear = 0.1;
    float zFar = 1000;
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
        glLoadIdentity();
        GLfloat frustum = zNear * tanf(GLKMathDegreesToRadians(_fieldOfView) / 2.0);
        glFrustumf(-frustum, frustum, -frustum/aspectRatio, frustum/aspectRatio, zNear, zFar);
        glMatrixMode(GL_MODELVIEW);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
    glPopMatrix();
}

-(void) setTexture:(NSString*)fileName{
    [sphere swapTexture:fileName];
}

-(void) setCelestialTexture:(NSString*)fileName{
    [celestial swapTexture:fileName];
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

-(void) setStars:(NSArray *)stars{
    RAAndDec = malloc(sizeof(GLfloat)*stars.count*2);
    for(int i = 0; i < stars.count; i++){
        RAAndDec[i*2] = [[[stars objectAtIndex:i] objectForKey:@"RA"] floatValue] / 24.0 * 2 * M_PI;
        RAAndDec[i*2+1] = [[[stars objectAtIndex:i] objectForKey:@"Dec"] floatValue] /180*(M_PI);
        if(i == 144){
            NSLog(@"SIRIUS: RA:%f, DEC:%f",[[[stars objectAtIndex:i] objectForKey:@"RA"] floatValue], [[[stars objectAtIndex:i] objectForKey:@"Dec"] floatValue]);
            NSLog(@"SIRIUS (in RADIANS): RA:%f, DEC:%f",RAAndDec[i*2], RAAndDec[i*2+1]);
        }
    }
    NSLog(@"Example star:%@",[stars objectAtIndex:1]);
    _stars = stars;
    
    [loadingDelegate starsDidLoad];
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
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                _attitudeMatrix =
                GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                               a.m13, a.m23, a.m33, 0.0f,
                               -a.m12,-a.m22,-a.m32,0.0f,
                               0.0f , 0.0f , 0.0f , 1.0f);
            }];
        }
    }
    else {
        [motionManager stopDeviceMotionUpdates];
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

-(void)execute{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GLfloat white[] = {1.0,1.0,1.0,1.0};
    
    glMatrixMode(GL_MODELVIEW);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, white);
 
    glPushMatrix();
        glMultMatrixf(_attitudeMatrix.m);
        if(_celestialSphere){
            glPushMatrix();
            glMultMatrixf(GLKMatrix4MakeRotation(M_PI/2.0, 0, 1, 0).m);  // for Hipparcos maps where RA 0 is at the edge
//            glMultMatrixf(GLKMatrix4MakeRotation(-M_PI/2.0, 0, 1, 0).m); // for Tycho where RA 0 is at the center
            [self executeSphere:celestial];
            glPopMatrix();
        }
        glPushMatrix();
            [self executeSphere:sphere];
        glPopMatrix();
    
        if(_stars != nil){
            static const GLfloat quadVertices[] = {
                -.001,  .001, -0.0,
                .001,  .001, -0.0,
                -.001, -.001, -0.0,
                .001, -.001, -0.0
            };
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            glDisable(GL_TEXTURE_2D);
            glEnableClientState(GL_VERTEX_ARRAY);
            glEnable(GL_CULL_FACE);
            glCullFace(GL_BACK);
            glFrontFace(GL_CW);
            // RA anchor point
            glPushMatrix();
                glTranslatef(0.0, 0.0, -1.0);
                glScalef(10.0, 10.0, 10.0);
                glColor4f(1.0, 1.0, 1.0, 1.0);
                glVertexPointer(3, GL_FLOAT, 0, quadVertices);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glPopMatrix();

            for(int i = 0; i < _stars.count; i++){
                glPushMatrix();
                    GLKMatrix4 ra = GLKMatrix4MakeRotation(RAAndDec[i*2], 0.0, 1.0, 0.0);
                    glMultMatrixf(ra.m);
                    GLKMatrix4 dec = GLKMatrix4MakeRotation(RAAndDec[i*2+1], 1.0, 0.0, 0.0);
                    glMultMatrixf(dec.m);
                    glTranslatef(0.0, 0.0, -1.0);
                    glColor4f(1.0, 1.0, 1.0, 1.0);
                    if(i == 144){
                        glScalef(10.0, 10.0, 10.0);
                        glColor4f(1.0, 0.2, 0.2, 1.0);
                    }
                    glVertexPointer(3, GL_FLOAT, 0, quadVertices);
                    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glPopMatrix();
            }
            glDisableClientState(GL_VERTEX_ARRAY);
        }
    if(_stars == nil){
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glEnable(GL_TEXTURE_2D);
       [loadingStage execute];
    }
    glPopMatrix();
}

-(void)executeSphere:(Sphere *)s{
    GLfloat posX, posY, posZ;
    [s getPositionX:&posX Y:&posY Z:&posZ];
    glTranslatef(posX, posY, posZ);
    [s execute];
}

@end