//
//  HUD.m
//  SpyAR
//
//  Created by Robby Kraft on 11/11/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "HUD.h"
#import <GLKit/GLKit.h>
#import "Word.h"

@implementation HUD{
    float _aspectRatio;
//    NSArray *textures;
    float *celestialFocus;
    float *look;
    CGPoint offset;
    Word *starName;
}

//@synthesize delegate;

-(id) init{
    self = [super init];
    if(self){
        _rotation = 0.0;
        _aspectRatio = (float)[[UIScreen mainScreen] bounds].size.width / (float)[[UIScreen mainScreen] bounds].size.height;
        if([UIApplication sharedApplication].statusBarOrientation > 2)
            _aspectRatio = 1/_aspectRatio;
        celestialFocus = malloc(sizeof(float)*2);
        look = malloc(sizeof(float)*2);
//        NSMutableArray *array = [NSMutableArray array];
//        for(int i = 0; i <= 6; i++){
//            GLKTextureInfo *texture;
//            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
//            NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"target%d.png",i] ofType:NULL];
//            texture=[GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
//            [array addObject:texture];
//        }
//        textures = array;
        starName = [[Word alloc] init];
    }
    return self;
}
-(void)setEyeVector:(GLKVector3)eyeVector{
    _eyeVector = eyeVector;
//    atan2f(_eyeVector.z, _eyeVector.x);
}
-(void)setCelestialFocusAzimuth:(float)a Altitude:(float)b{
    celestialFocus[AZIMUTH] = a;
    celestialFocus[ALTITUDE] = b;
//    NSLog(@"%f, %f",celestialFocus[AZIMUTH], celestialFocus[ALTITUDE]);
}
-(void)setLookAzimuth:(float)a Altitude:(float)b{
    look[AZIMUTH] = a;
    look[ALTITUDE] = b;
}
-(void) execute{   
    
//    static const GLfloat hexVertices[] = {
//        -.5f, -.8660254f, -1.0f, 0.0f, -.5f, .8660254f,
//        .5f, .8660254f,    1.0f, 0.0f,  .5f, -.8660254f
//    };
//    static const GLfloat quadVertices[] = {
//        -1.0,  1.0,
//        1.0,  1.0,
//        -1.0, -1.0,
//        1.0, -1.0
//    };
    
//    static const GLfloat quadVertices[] = {
//        -1.0,  1.0, -0.0,
//        1.0,  1.0, -0.0,
//        -1.0, -1.0, -0.0,
//        1.0, -1.0, -0.0
//    };
//    static const GLfloat quadNormals[] = {
//        0.0, 0.0, 1.0,
//        0.0, 0.0, 1.0,
//        0.0, 0.0, 1.0,
//        0.0, 0.0, 1.0
//    };
//    static const GLfloat quadTextureCoords[] = {
//        0.0, 1.0,
//        1.0, 1.0,
//        0.0, 0.0,
//        1.0, 0.0
//    };

    static const GLfloat octVertices[] = {
        0.0f, 1.0f, .7071f, .7071f, 1.0f, 0.0f, .7071f, -.7071f,
        0.0f, -1.0f, -.7071f, -.7071f, -1.0f, 0.0f, -.7071f, .7071f
    };
    
    [self switchToOrtho];
    CGFloat HUD_RADIUS = 4.0;
    
    glLineWidth(1.0);
    glTranslatef([[UIScreen mainScreen] bounds].size.height*.5, [[UIScreen mainScreen] bounds].size.width*.5, 0.0);
    glScalef(HUD_RADIUS/_aspectRatio, HUD_RADIUS*_aspectRatio, 1);
    
    // reticle
    glColor4f(0.5, 0.5, 1.0, 1.0); // blue
    glVertexPointer(2, GL_FLOAT, 0, octVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glPushMatrix();
        glDrawArrays(GL_LINE_LOOP, 0, 8);
    glPopMatrix();
    // star name
    glPushMatrix();
        glTranslatef(-5., -45., 0.0);
        [starName execute];
    glPopMatrix();
    
    glLoadIdentity();
    
    [self switchBackToFrustum];

//    glPushMatrix();
//        offset = CGPointMake(look[AZIMUTH] - celestialFocus[AZIMUTH], look[ALTITUDE] - celestialFocus[ALTITUDE]);
//        glTranslatef(-offset.x*200, offset.y*200, 0.0);
//        glDrawArrays(GL_LINE_LOOP, 0, 8);
//    glPopMatrix();
//    glPushMatrix();
//        glVertexPointer(2, GL_FLOAT, 0, quadVertices);
//        glTranslatef(-look[AZIMUTH]*75,look[ALTITUDE]*75, 0.0);
//        glDrawArrays(GL_LINE_LOOP, 0, 4);
//    glPopMatrix();

//    glScalef(1.175, 1.175, 1);
//    glRotatef(_rotation, 0, 0, 1);
//    glDrawArrays(GL_LINE_LOOP, 0, 8);
    
/*    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CW);
    
    glScalef(2.0, 2.0, 2.0);

    glEnableClientState(GL_VERTEX_ARRAY);
//    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
//    glBindTexture(GL_TEXTURE_2D, [(GLKTextureInfo*)(textures[textureIndex]) name]);
    glVertexPointer(2, GL_FLOAT, 0, quadVertices);
//    glNormalPointer(GL_FLOAT, 0, quadNormals);
    glTexCoordPointer(2, GL_FLOAT, 0, quadTextureCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
*/
}

-(void)updateStarName:(NSString *)string{
    [starName setText:string];
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

-(void)switchToOrtho{
    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrthof(0, [[UIScreen mainScreen] bounds].size.height, 0, [[UIScreen mainScreen] bounds].size.width, -5, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

-(void)switchBackToFrustum{
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
}
@end
