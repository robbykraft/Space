//
//  Stars.m
//  Space
//
//  Created by Robby Kraft on 11/10/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "Stars.h"
#import "Sphere.h"

#define SLICES 48

@implementation Stars{
    Sphere *lines;
    Sphere *constellations;
    GLfloat *positions;
    int starCount;
    float *look;
}

@synthesize delegate;

-(id) init{
    self = [super init];
    if (self) {
        look = malloc(sizeof(float)*2);
        lines = [[Sphere alloc] init:SLICES slices:SLICES radius:900.0 squash:1.0 textureFile:@"equirectangular-projection-lines.png"];
        constellations = [[Sphere alloc] init:SLICES slices:SLICES radius:950.0 squash:1.0 textureFile:@"Hipparcos_2048_B&W_reflection.png"];
    }
    return self;
}
-(void)setStarCatalog:(NSArray *)starCatalog{
    starCount = (int)starCatalog.count;
    positions = malloc(sizeof(GLfloat)*starCount*3);
    for(int i = 0; i < starCatalog.count; i++){
        positions[i*3+AZIMUTH] = [[[starCatalog objectAtIndex:i] objectForKey:@"RA"] floatValue] / 24.0 * 2 * M_PI;
        positions[i*3+ALTITUDE] = [[[starCatalog objectAtIndex:i] objectForKey:@"Dec"] floatValue] /180*(M_PI);
        positions[i*3+DISTANCE] = [[[starCatalog objectAtIndex:i] objectForKey:@"Distance"] floatValue] /180*(M_PI);
    }
    _starCatalog = starCatalog;
    [delegate starsDidLoad];
}
-(void)setLookAzimuth:(float)a Altitude:(float)b{
    look[AZIMUTH] = a;
    look[ALTITUDE] = b;
}

-(float*)getNearestStarToAzimuth:(float)a Altitude:(float)b{
    look[AZIMUTH] = a;
    look[ALTITUDE] = b;
    float closestDistance = fabsf(a-positions[0+AZIMUTH]) + fabsf(b-positions[0+ALTITUDE]);
    int closestIndex = 0;
    float newDistance;
    for(int i = 1; i < starCount; i++){
        newDistance = fabsf(-positions[i*3+AZIMUTH]-a) + fabsf(positions[i*3+ALTITUDE]-b);
        if(newDistance < closestDistance){
            closestDistance = newDistance;
            closestIndex = i;
        }
    }
    float *starPosition = malloc(sizeof(float)*2);
    starPosition[AZIMUTH] = positions[closestIndex*3+AZIMUTH];
    starPosition[ALTITUDE] = positions[closestIndex*3+ALTITUDE];
    return starPosition;
}
-(void)execute{
//    glMultMatrixf(GLKMatrix4MakeRotation(M_PI/2.0, 0, 1, 0).m);  // for Hipparcos maps where RA 0 is at the edge

    glPushMatrix();
    // one or the other
//        glMultMatrixf(GLKMatrix4MakeRotation(-M_PI/2.0, 0, 1, 0).m);  // for Hipparcos maps where RA 0 is at the edge
//        glMultMatrixf(GLKMatrix4MakeRotation(-M_PI/2.0, 0, 1, 0).m); // for Tycho where RA 0 is at the center
//        [constellations execute];
    glPopMatrix();
    glPushMatrix();
        [lines execute];
    glPopMatrix();
    
    if(_starCatalog != nil){
//        static const GLfloat quadVertices[] = {
//            -.001,  .001, -0.0,
//            .001,  .001, -0.0,
//            -.001, -.001, -0.0,
//            .001, -.001, -0.0
//        };
        static const GLfloat quadVertices[] = {
            0.0,  .001, -.001,
            0.0,  .001,  .001,
            0.0, -.001, -.001,
            0.0, -.001,  .001,
        };
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisable(GL_TEXTURE_2D);
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glFrontFace(GL_CW);
        // RA anchor point
        glPushMatrix();
            GLKMatrix4 az = GLKMatrix4MakeRotation(-look[AZIMUTH], 0.0, 1.0, 0.0);
            glMultMatrixf(az.m);
            GLKMatrix4 alt = GLKMatrix4MakeRotation(look[ALTITUDE], 0.0, 0.0, 1.0);
            glMultMatrixf(alt.m);
            glTranslatef(1.0, 0.0, 0.0);
            glScalef(1.0, 10.0, 10.0);
            glColor4f(1.0, 1.0, 1.0, 1.0);
            glVertexPointer(3, GL_FLOAT, 0, quadVertices);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glPopMatrix();
        
        for(int i = 0; i < _starCatalog.count; i++){
            glPushMatrix();
            glScalef(positions[i*3+DISTANCE]*100, positions[i*3+DISTANCE]*100, positions[i*3+DISTANCE]*100);
            GLKMatrix4 ra = GLKMatrix4MakeRotation(positions[i*3+AZIMUTH], 0.0, 1.0, 0.0);
            glMultMatrixf(ra.m);
            GLKMatrix4 dec = GLKMatrix4MakeRotation(positions[i*3+ALTITUDE], 0.0, 0.0, 1.0);
            glMultMatrixf(dec.m);
            glTranslatef(1.0, 0.0, 0.0);
            glColor4f(1.0, 1.0, 1.0, 1.0);
//            if(i == 144){  // sirius
//                glScalef(10., 10., 10.);
//            }
            glVertexPointer(3, GL_FLOAT, 0, quadVertices);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glPopMatrix();
        }
        glDisableClientState(GL_VERTEX_ARRAY);
    }
}
@end
