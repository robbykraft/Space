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
    NSArray *names;
    NSArray *planetTextures;
}

@synthesize delegate;

-(id) init{
    self = [super init];
    if (self) {     
        planetSphere = [[Sphere alloc] init:SLICES slices:SLICES radius:1.0 squash:1.0 textureFile:nil];
        names = @[@"Mercury", @"Venus", @"Earth", @"Mars", @"Jupiter", @"Saturn", @"Uranus", @"Neptune"];
        planetTextures = [self loadPlanetTextures];
    }
    return self;
}

-(void)setDistantPlanets:(NSArray *)distantPlanets{
    _distantPlanets = distantPlanets;
}

-(void)execute{    
//    glRotatef(23.4, 1, 0, 0);   // align ecliptic plane
    if(_distantPlanets != nil){
        static const GLfloat distances[] = { 0.39, 0.723, 1.0, 1.524, 5.203, 9.539, 19.18, 30.06 };
        static const GLfloat rotations[] = { .666, .4166, .5, .73, .64, .97, .416, .55 };
        static const GLfloat rectangleVertices[] = {
            -.015,  .01, -0.0,
            .015,  .01, -0.0,
            -.015, -.01, -0.0,
            .015, -.01, -0.0
        };
        static const GLfloat quadVertices[] = {
            -.01,  .01, -0.0,
            .01,  .01, -0.0,
            -.01, -.01, -0.0,
            .01, -.01, -0.0
        };
        static const GLfloat quadNormals[] = {
            0.0, 0.0, 1.0,
            0.0, 0.0, 1.0,
            0.0, 0.0, 1.0,
            0.0, 0.0, 1.0
        };
        static const GLfloat quadTextureCoords[] = {
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        };

        glEnable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glFrontFace(GL_CW);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        for(int i = 0; i < _distantPlanets.count; i++){
            glPushMatrix();
            glScalef(distances[i], distances[i], distances[i]);
            // need planet rotation amount
//            glRotatef(rotations[i]*360.0, 0, 1, 0);
            glRotatef(-(90+38), 0, 1, 0);  // sun
            glRotatef(rotations[i]*360, 0, 1, 0);  // planet angle from zodiac
            glTranslatef(0.0, 0.0, -1.0);
            glColor4f(1.0, 1.0, 1.0, 1.0);
            glBindTexture(GL_TEXTURE_2D, ((GLKTextureInfo*)(planetTextures[i])).name);
            if(i == Saturn)
                glVertexPointer(3, GL_FLOAT, 0, rectangleVertices);
            else
                glVertexPointer(3, GL_FLOAT, 0, quadVertices);
            glNormalPointer(GL_FLOAT, 0, quadNormals);
            glTexCoordPointer(2, GL_FLOAT, 0, quadTextureCoords);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glPopMatrix();
        }
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
}

-(NSArray*)loadPlanetTextures{
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < NUM_PLANETS; i++){
        GLKTextureInfo *texture;
        texture = [self loadTexture:[NSString stringWithFormat:@"%@.png",names[i]]];
        [array addObject:texture];
    }
    return array;
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

@end
