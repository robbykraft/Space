//
//  Word.m
//  Space
//
//  Created by Robby Kraft on 12/7/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "Word.h"
#import <GLKit/GLKit.h>

@interface Word (){
    NSDictionary *textures;
    NSArray *letterTextures;
}
@end

@implementation Word

-(id)initWithString:(NSString*)string{
    self = [self init];
    [self setText:string];
    return self;
}

-(id) init{
    self = [super init];
    if(self){
        textures = [NSDictionary dictionaryWithObjectsAndKeys:
                    [self loadTexture:@"A.png"], @"A",
                    [self loadTexture:@"B.png"], @"B",
                    [self loadTexture:@"C.png"], @"C",
                    [self loadTexture:@"D.png"], @"D",
                    [self loadTexture:@"E.png"], @"E",
                    [self loadTexture:@"F.png"], @"F",
                    [self loadTexture:@"G.png"], @"G",
                    [self loadTexture:@"H.png"], @"H",
                    [self loadTexture:@"I.png"], @"I",
                    [self loadTexture:@"J.png"], @"J",
                    [self loadTexture:@"K.png"], @"K",
                    [self loadTexture:@"L.png"], @"L",
                    [self loadTexture:@"M.png"], @"M",
                    [self loadTexture:@"N.png"], @"N",
                    [self loadTexture:@"O.png"], @"O",
                    [self loadTexture:@"P.png"], @"P",
                    [self loadTexture:@"Q.png"], @"Q",
                    [self loadTexture:@"R.png"], @"R",
                    [self loadTexture:@"S.png"], @"S",
                    [self loadTexture:@"T.png"], @"T",
                    [self loadTexture:@"U.png"], @"U",
                    [self loadTexture:@"V.png"], @"V",
                    [self loadTexture:@"W.png"], @"W",
                    [self loadTexture:@"X.png"], @"X",
                    [self loadTexture:@"Y.png"], @"Y",
                    [self loadTexture:@"Z.png"], @"Z",
                    [self loadTexture:@"0.png"], @"0",
                    [self loadTexture:@"1.png"], @"1",
                    [self loadTexture:@"2.png"], @"2",
                    [self loadTexture:@"3.png"], @"3",
                    [self loadTexture:@"4.png"], @"4",
                    [self loadTexture:@"5.png"], @"5",
                    [self loadTexture:@"6.png"], @"6",
                    [self loadTexture:@"7.png"], @"7",
                    [self loadTexture:@"8.png"], @"8",
                    [self loadTexture:@"9.png"], @"9",
                    [self loadTexture:@"_.png"], @" ",
                    nil];
    }
    return self;
}

-(void) setText:(NSString *)text{
    NSMutableArray *textureArray = [NSMutableArray array];
    for(int i = 0; i < text.length; i++){
        NSString *letter = [[text substringWithRange:NSMakeRange(i, 1)] uppercaseString];
        if([letter isEqualToString:@"A"] ||
           [letter isEqualToString:@"B"] ||
           [letter isEqualToString:@"C"] ||
           [letter isEqualToString:@"D"] ||
           [letter isEqualToString:@"E"] ||
           [letter isEqualToString:@"F"] ||
           [letter isEqualToString:@"G"] ||
           [letter isEqualToString:@"H"] ||
           [letter isEqualToString:@"I"] ||
           [letter isEqualToString:@"J"] ||
           [letter isEqualToString:@"K"] ||
           [letter isEqualToString:@"L"] ||
           [letter isEqualToString:@"M"] ||
           [letter isEqualToString:@"N"] ||
           [letter isEqualToString:@"O"] ||
           [letter isEqualToString:@"P"] ||
           [letter isEqualToString:@"Q"] ||
           [letter isEqualToString:@"R"] ||
           [letter isEqualToString:@"S"] ||
           [letter isEqualToString:@"T"] ||
           [letter isEqualToString:@"U"] ||
           [letter isEqualToString:@"V"] ||
           [letter isEqualToString:@"W"] ||
           [letter isEqualToString:@"X"] ||
           [letter isEqualToString:@"Y"] ||
           [letter isEqualToString:@"Z"] ||
           [letter isEqualToString:@"0"] ||
           [letter isEqualToString:@"1"] ||
           [letter isEqualToString:@"2"] ||
           [letter isEqualToString:@"3"] ||
           [letter isEqualToString:@"4"] ||
           [letter isEqualToString:@"5"] ||
           [letter isEqualToString:@"6"] ||
           [letter isEqualToString:@"7"] ||
           [letter isEqualToString:@"8"] ||
           [letter isEqualToString:@"9"] ||
           [letter isEqualToString:@" "] ){
            [textureArray addObject:[textures objectForKey:letter]];
        }
    }
    letterTextures = textureArray;
    _text = text;
}
-(void) execute{

    static const GLfloat rectangleVertices[] = {
        -1.0,  1.5,
        1.0,  1.5,
        -1.0, -1.5,
        1.0, -1.5
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
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glPushMatrix();

    for(int i = 0; i < letterTextures.count; i++){
        glPushMatrix();
        glTranslatef(i*2.5, 0.0, 0.0);
        glBindTexture(GL_TEXTURE_2D, [(GLKTextureInfo*)(letterTextures[i]) name]);
        glVertexPointer(2, GL_FLOAT, 0, rectangleVertices);
        glTexCoordPointer(2, GL_FLOAT, 0, quadTextureCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glPopMatrix();
    }
    glPopMatrix();
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
