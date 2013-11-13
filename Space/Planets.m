//
//  Planets.m
//  Space
//
//  Created by Robby Kraft on 11/12/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "Planets.h"
#import "Sphere.h"

#define SLICES 48

#define NUM_PLANETS 8

typedef enum{
    Mercury,
    Venus,
    Earth,
    Mars,
    Jupiter,
    Saturn,
    Uranus,
    Neptune
}
PlanetName;

@implementation Planets{
    Sphere *planetSphere;
    GLfloat *positions;
}

@synthesize delegate;

-(id) init{
    self = [super init];
    if (self) {     
        planetSphere = [[Sphere alloc] init:SLICES slices:SLICES radius:1.0 squash:1.0 textureFile:nil];
    }
    return self;
}

-(void)execute{    
    if(_distantPlanets != nil){
        static const GLfloat distances[] = { 0.39, 0.723, 1.0, 1.524, 5.203, 9.539, 19.18, 30.06 };
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
        
        for(int i = 0; i < NUM_PLANETS; i++){
            glPushMatrix();
            glScalef(distances[i], distances[i], distances[i]);
            // need planet rotation amount
//            GLKMatrix4 ra = GLKMatrix4MakeRotation(positions[i*3+RA], 0.0, 1.0, 0.0);
//            glMultMatrixf(ra.m);
            glTranslatef(0.0, 0.0, -1.0);
            glColor4f(1.0, 1.0, 1.0, 1.0);
            glVertexPointer(3, GL_FLOAT, 0, quadVertices);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glPopMatrix();
        }
        glDisableClientState(GL_VERTEX_ARRAY);
    }
}
@end
