///
//  Stars.m
//  Space
//
//  Created by Robby Kraft on 11/10/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "Stars.h"
#import "Sphere.h"
#import "Star.h"

#define SLICES 48

@implementation Stars{
    Sphere *lines;
    Sphere *constellations;
    GLfloat *positions;
    int starCount;
    float *look;
    NSMutableArray *names;
    GLfloat *magnitudes;
    NSArray *celestialStars;
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
    magnitudes = malloc(sizeof(GLfloat)*starCount);
    names = [NSMutableArray array];
    NSMutableArray *starCache = [NSMutableArray array];
    for(int i = 0; i < starCatalog.count; i++){
        Star *star = [[Star alloc] initWithAzimuth:[[[starCatalog objectAtIndex:i] objectForKey:@"RA"] floatValue] / 24.0 * 2 * M_PI
                                          Altitude:[[[starCatalog objectAtIndex:i] objectForKey:@"Dec"] floatValue] /180*(M_PI)
                                          Distance:[[[starCatalog objectAtIndex:i] objectForKey:@"Distance"] floatValue] /180*(M_PI)];
        [star setName:[starCatalog[i] objectForKey:@"Name"]];
        [star setMagnitude:[[starCatalog[i] objectForKey:@"Mag"] floatValue]];
        [starCache addObject:star];
        
        positions[i*3+AZIMUTH] = star.position[AZIMUTH];
        positions[i*3+ALTITUDE] = star.position[ALTITUDE];
        positions[i*3+DISTANCE] = star.position[DISTANCE];
        [names addObject:star.name];
        magnitudes[i] = star.magnitude;
    }
    celestialStars = starCache;
    _starCatalog = starCatalog;
    [delegate starsDidLoad];
}
-(void)setLookAzimuth:(float)a Altitude:(float)b{
    look[AZIMUTH] = a;
    look[ALTITUDE] = b;
}

-(Star*)nearestStarToAzimuth:(float)a Altitude:(float)b{
    look[AZIMUTH] = a;
    look[ALTITUDE] = b;
//    float closestDistance = fabsf(-[celestialStars[0] azimuth]-a) + fabsf([celestialStars[0] altitude]-b);
    float closestDistance = fabsf(a-positions[0+AZIMUTH]) + fabsf(b-positions[0+ALTITUDE]);
    int closestIndex = 0;
    float newDistance;
    for(int i = 1; i < starCount; i++){
        newDistance = fabsf(positions[i*3+AZIMUTH]-a) + fabsf(positions[i*3+ALTITUDE]-b);
//        newDistance = fabsf(-[celestialStars[i] azimuth]-a) + fabsf([celestialStars[i] altitude]-b);
        if(newDistance < closestDistance){
            closestDistance = newDistance;
            closestIndex = i;
        }
    }
    return celestialStars[closestIndex];
}

-(void)execute{
    glPushMatrix();
    // one or the other
//        glMultMatrixf(GLKMatrix4MakeRotation(-M_PI/2.0, 0, 1, 0).m);  // for Hipparcos maps where RA 0 is at the edge
//        glMultMatrixf(GLKMatrix4MakeRotation(-M_PI/2.0, 0, 1, 0).m); // for Tycho where RA 0 is at the center
//        [constellations execute];
    glPopMatrix();
    glPushMatrix();
        [lines execute];
    glPopMatrix();

    
//    glPushMatrix();
//    GLKMatrix4 az = GLKMatrix4MakeRotation(lookAzimuth, 0.0, 1.0, 0.0);
//    glMultMatrixf(az.m);
//    GLKMatrix4 alt = GLKMatrix4MakeRotation(lookAltitude, 0.0, 0.0, 1.0);
//    glMultMatrixf(alt.m);
//    glTranslatef(1.0, 0.0, 0.0);
//    glScalef(1.0, 10.0, 10.0);
//    glColor4f(1.0, 1.0, 1.0, 1.0);
//    glVertexPointer(3, GL_FLOAT, 0, quadVertices);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glPopMatrix();

//    glPushMatrix();
//    GLKMatrix4 ra3 = GLKMatrix4MakeRotation(lookAzimuth, 0.0, 1.0, 0.0);
//    glMultMatrixf(ra3.m);
//    GLKMatrix4 dec3 = GLKMatrix4MakeRotation(lookAltitude, 0.0, 0.0, 1.0);
//    glMultMatrixf(dec3.m);
//    glTranslatef(1.0, 0.0, 0.0);
//    glColor4f(1.0, 1.0, 1.0, 1.0);
//    glScalef(200.0, 200.0, 200.0);
//    glDisable(GL_BLEND);
//    glBindTexture(GL_TEXTURE_2D, jupiterTexture.name);
//    glVertexPointer(3, GL_FLOAT, 0, quadVertices);
//    glNormalPointer(GL_FLOAT, 0, quadNormals);
//    glTexCoordPointer(2, GL_FLOAT, 0, quadTextureCoords);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glPopMatrix();
//    
//    glPushMatrix();
//    GLKMatrix4 ra2 = GLKMatrix4MakeRotation(lookAzimuth, 0.0, 1.0, 0.0);
//    glMultMatrixf(ra2.m);
//    GLKMatrix4 dec2 = GLKMatrix4MakeRotation(lookAltitude, 0.0, 0.0, 1.0);
//    glMultMatrixf(dec2.m);
//    glTranslatef(.50, 0.0, 0.0);
//    glColor4f(1.0, 1.0, 1.0, 1.0);
//    glScalef(100.0, 100.0, 100.0);
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_DST_COLOR, GL_ZERO);
//    glBindTexture(GL_TEXTURE_2D, maskTexture.name);
//    glVertexPointer(3, GL_FLOAT, 0, quadVertices);
//    glNormalPointer(GL_FLOAT, 0, quadNormals);
//    glTexCoordPointer(2, GL_FLOAT, 0, quadTextureCoords);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glPopMatrix();

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
        
        for(int i = 0; i < _starCatalog.count; i++){
            glPushMatrix();
//            float dist = ((Star*)celestialStars[i]).position[DISTANCE];
//            glScalef(dist*100., dist*100., dist*100.);
            glScalef(positions[i*3+DISTANCE]*100, positions[i*3+DISTANCE]*100, positions[i*3+DISTANCE]*100);
//            GLKMatrix4 ra = GLKMatrix4MakeRotation([celestialStars[i] azimuth], 0.0, 1.0, 0.0);
            GLKMatrix4 ra = GLKMatrix4MakeRotation(positions[i*3+AZIMUTH], 0.0, 1.0, 0.0);
            glMultMatrixf(ra.m);
//            GLKMatrix4 dec = GLKMatrix4MakeRotation([celestialStars[i] altitude], 0.0, 0.0, 1.0);
            GLKMatrix4 dec = GLKMatrix4MakeRotation(positions[i*3+ALTITUDE], 0.0, 0.0, 1.0);
            glMultMatrixf(dec.m);
            glTranslatef(1.0, 0.0, 0.0);
            glColor4f(1.0, 1.0, 1.0, 1.0);
//            if(i == 144){  // sirius
//                glScalef(10., 10., 10.);
//            }
            glScalef(1.0, 3/sqrt(magnitudes[i]), 3/sqrt(magnitudes[i]));
            glVertexPointer(3, GL_FLOAT, 0, quadVertices);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glPopMatrix();
        }
        glDisableClientState(GL_VERTEX_ARRAY);
    }
}
@end
