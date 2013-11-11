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

#define RA 0
#define DEC 1
#define DISTANCE 2

@implementation Stars{
    Sphere *lines;
    Sphere *constellations;
    GLfloat *positions;
}

@synthesize delegate;

-(id) init{
    self = [super init];
    if (self) {     
        lines = [[Sphere alloc] init:SLICES slices:SLICES radius:20.0 squash:1.0 textureFile:@"equirectangular-projection-lines.png"];
        constellations = [[Sphere alloc] init:SLICES slices:SLICES radius:30.0 squash:1.0 textureFile:@"Hipparcos_2048_B&W_reflection.png"];
    }
    return self;
}
-(void)setStarCatalog:(NSArray *)starCatalog{
    positions = malloc(sizeof(GLfloat)*starCatalog.count*3);
    for(int i = 0; i < starCatalog.count; i++){
        positions[i*3+RA] = [[[starCatalog objectAtIndex:i] objectForKey:@"RA"] floatValue] / 24.0 * 2 * M_PI;
        positions[i*3+DEC] = [[[starCatalog objectAtIndex:i] objectForKey:@"Dec"] floatValue] /180*(M_PI);
        positions[i*3+DISTANCE] = [[[starCatalog objectAtIndex:i] objectForKey:@"Distance"] floatValue] /180*(M_PI);
    }
    _starCatalog = starCatalog;
    [delegate starsDidLoad];
}
-(void)execute{
    glPushMatrix();
        glMultMatrixf(GLKMatrix4MakeRotation(M_PI/2.0, 0, 1, 0).m);  // for Hipparcos maps where RA 0 is at the edge
//        glMultMatrixf(GLKMatrix4MakeRotation(-M_PI/2.0, 0, 1, 0).m); // for Tycho where RA 0 is at the center
//        [constellations execute];
    glPopMatrix();
//    glPushMatrix();
//        [lines execute];
//    glPopMatrix();
    
    if(_starCatalog != nil){
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
        
        for(int i = 0; i < _starCatalog.count; i++){
            glPushMatrix();
            glScalef(positions[i*3+DISTANCE], positions[i*3+DISTANCE], positions[i*3+DISTANCE]);
            GLKMatrix4 ra = GLKMatrix4MakeRotation(positions[i*3+RA], 0.0, 1.0, 0.0);
            glMultMatrixf(ra.m);
            GLKMatrix4 dec = GLKMatrix4MakeRotation(positions[i*3+DEC], 1.0, 0.0, 0.0);
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
}
@end
