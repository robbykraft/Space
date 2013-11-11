//
//  PanoramaView.m
//  Space
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "LoadingStage.h"
#import "Sphere.h"

#define SLICES 48

@interface LoadingStage (){
    Sphere *lines;
    Sphere *tychoStars;
    GLKTextureInfo *messageTextureInfo;
}
@end

@implementation LoadingStage

-(id) init{
    self = [super init];
    if (self) {
        lines = [[Sphere alloc] init:SLICES slices:SLICES radius:5.0 squash:1.0 textureFile:@"equirectangular-projection-lines.png"];
        tychoStars = [[Sphere alloc] init:SLICES slices:SLICES radius:7.0 squash:1.0 textureFile:@"Tycho_2048_city_reflection.png"];
        messageTextureInfo = [self loadTexture:@"buildingTheUniverse.png"];
    }
    return self;
}
-(void)executeSquare{
    static const GLfloat quadVertices[] = {
        -1.0,  1.0, -0.0,
        1.0,  1.0, -0.0,
        -1.0, -1.0, -0.0,
        1.0, -1.0, -0.0
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
    
    for(int i = 0; i < 4; i++){
        GLKMatrix4 rotation = GLKMatrix4MakeRotation(M_PI*.5*i, 0.0, 1.0, 0.0);
        glPushMatrix();
        glMultMatrixf(rotation.m);
        glTranslatef(0.0, 0.0, -2.0);
        glBindTexture(GL_TEXTURE_2D, messageTextureInfo.name);
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
    static float spin;
    spin += .01;
    if(spin >= 24) spin = 0;
    
    // made-up figures to fake a spinning planet
    GLKMatrix4 latitude = GLKMatrix4MakeRotation(M_PI/180.0*45.0, 0, 0, 1);
    GLKMatrix4 earthTilt = GLKMatrix4MakeRotation(M_PI/180.0*23.45, 1, 0, 0);
    GLKMatrix4 day = GLKMatrix4MakeRotation(2*M_PI/24.0*spin, 0, 1, 0);
    
    glPushMatrix();
        glMultMatrixf(latitude.m);
        glMultMatrixf(earthTilt.m);
        glMultMatrixf(day.m);
        [tychoStars execute];
    glPopMatrix();
    glPushMatrix();
        [lines execute];
        [self executeSquare];
    glPopMatrix();
}

- (void)dealloc{
    NSLog(@"dealloc LoadingStage");
    [lines deleteTexture];
    lines = nil;
    [tychoStars deleteTexture];
    tychoStars = nil;
    
//    free(rotationRates);
}


@end