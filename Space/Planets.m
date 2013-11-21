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
#define x 0
#define y 1
#define z 2
#define π M_PI

#define OBJECTS 8
typedef enum{
    Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto
} Planet;

@implementation Planets{
    Sphere *planetSphere;
    double positions[OBJECTS*3];
    NSArray *names;
    NSArray *planetTextures;
    double distances[OBJECTS];
    double azimuths[OBJECTS];
}

@synthesize delegate;

// today's date. progression through 2013 320 / 365  (dec: .8767)
// + 12 years since 2000
// .12 + .008767   in centuries
// .128767
-(id) init{
    return [self initWithTime:.128767];  // mid Nov. 2013
}
-(id) initWithTime:(float)J2000{
    self = [super init];
    if (self) {
        planetSphere = [[Sphere alloc] init:SLICES slices:SLICES radius:9999.0 squash:1.0 textureFile:@"equatorial_line.png"];
        names = @[@"Mercury", @"Venus", @"Earth", @"Mars", @"Jupiter", @"Saturn", @"Uranus", @"Neptune"];
        planetTextures = [self loadPlanetTextures];
        _time = J2000;
        [self calculate];
    }
    return self;
}

-(void)calculate{
    for(int i = 0; i < OBJECTS; i++){
        double *planetPos = [self calculateLocationOfPlanet:i AtTime:_time];
        positions[3*i+x] = planetPos[x];
        positions[3*i+y] = planetPos[y];
        positions[3*i+z] = planetPos[z];
//        NSLog(@"%@: (%f, %f, %f)",[names objectAtIndex:i], positions[3*i+x], positions[3*i+y], positions[3*i+z]);
        distances[i] = sqrt(planetPos[x] * planetPos[x] +
                            planetPos[y] * planetPos[y] +
                            planetPos[z] * planetPos[z] );
//        NSLog(@"Orbit radius: %f", distances[i]);
        azimuths[i] = 180./π*atan2( positions[3*i+x], positions[3*i+y]);
//        NSLog(@"%f",azimuths[i]);
    }
}

// http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf
//                               a                e                I                 L            long.peri.       long.node.
//                              AU               rad              deg               deg              deg              deg
static double elements[] = {0.38709927,      0.20563593,      7.00497902,      252.25032350,     77.45779628,     48.33076593,  //mercury
                            0.72333566,      0.00677672,      3.39467605,      181.97909950,    131.60246718,     76.67984255,  //venus
                            1.00000261,      0.01671123,     -0.00001531,      100.46457166,    102.93768193,      0.0,         //earth moon barycenter
                            1.52371034,      0.09339410,      1.84969142,       -4.55343205,    -23.94362959,     49.55953891,  //mars
                            5.20288700,      0.04838624,      1.30439695,       34.39644051,     14.72847983,    100.47390909,  //jupiter
                            9.53667594,      0.05386179,      2.48599187,       49.95424423,     92.59887831,    113.66242448,  //saturn
                            19.18916464,      0.04725744,      0.77263783,      313.23810451,    170.95427630,     74.01692503, //uranus
                            30.06992276,      0.00859048,      1.77004347,      -55.12002969,     44.96476227,    131.78422574, //neptune
                            39.48211675,      0.24882730,     17.14001206,      238.92903833,    224.06891629,    110.30393684 };//pluto
//                         AU/Cy           rad/Cy           deg/Cy           deg/Cy              deg/Cy           deg/Cy
static double rates[] = {0.00000037,      0.00001906,     -0.00594749,   149472.67411175,      0.16047689,     -0.12534081,  //mercury
                         0.00000390,     -0.00004107,     -0.00078890,    58517.81538729,      0.00268329,     -0.27769418,  //venus
                         0.00000562,     -0.00004392,     -0.01294668,    35999.37244981,      0.32327364,      0.0,         //earth moon barycenter
                         0.00001847,      0.00007882,     -0.00813131,    19140.30268499,      0.44441088,     -0.29257343,  //mars
                        -0.00011607,     -0.00013253,     -0.00183714,     3034.74612775,      0.21252668,      0.20469106, //jupiter
                        -0.00125060,     -0.00050991,      0.00193609,     1222.49362201,     -0.41897216,     -0.28867794, //saturn
                        -0.00196176,     -0.00004397,     -0.00242939,      428.48202785,      0.40805281,      0.04240589, //uranus
                         0.00026291,      0.00005105,      0.00035372,      218.45945325,     -0.32241464,     -0.00508664,  //neptune
                        -0.00031596,      0.00005170,      0.00004818,      145.20780515,     -0.04062942,     -0.01183482 };//pluto

// location of planet in the J2000 ecliptic plane, with the X-axis aligned toward the equinox
-(double*)calculateLocationOfPlanet:(Planet)planet AtTime:(float)time{
    static double ecliptic[3];
    double *planet0 = &elements[6*planet];
    double *per_century = &rates[6*planet];
    // step 1
    // compute the value of each of that planet's six elements
    double a = planet0[0] + per_century[0]*time;    // (au) semi_major_axis
    double e = planet0[1] + per_century[1]*time;    //  ( ) eccentricity
    double I = planet0[2] + per_century[2]*time;    //  (°) inclination
    double L = planet0[3] + per_century[3]*time;    //  (°) mean_longitude
    double ϖ = planet0[4] + per_century[4]*time;    //  (°) longitude_of_periapsis
    double Ω = planet0[5] + per_century[5]*time;    //  (°) longitude_of_the_ascending_node
    
    // step 2
    // compute the argument of perihelion, ω, and the mean anomaly, M
    double ω = ϖ - Ω;
    double M = L - ϖ;
    
    // step 3a
    // modulus the mean anomaly so that -180° ≤ M ≤ +180°
    while(M > 180) M-=360;  // in degrees
    
    // step 3b
    // obtain the eccentric anomaly, E, from the solution of Kepler's equation
    //   M = E - e*sinE
    //   where e* = 180/πe = 57.29578e
    double E = M + (e*180./π) * sin(M*π/180.);  // E0
    for(int i = 0; i < 5; i++){  // iterate for precision, 10^(-6) degrees is sufficient
        E = [self KeplersEquation:E M:M e:e];
    }
    
    // step 4
    // compute the planet's heliocentric coordinates in its orbital plane, r', with the x'-axis aligned from the focus to the perihelion
    ω = ω * π/180.;
    E = E * π/180.;
    I = I * π/180.;
    Ω = Ω * π/180.;
    double x0 = a*(cos(E)-e);
    double y0 = a*sqrt(1-e*e)*sin(E);
    
    // step 5
    // compute the coordinates in the J2000 ecliptic plane, with the x-axis aligned toward the equinox:
    ecliptic[x] = ( cos(ω)*cos(Ω) - sin(ω)*sin(Ω)*cos(I) )*x0 + ( -sin(ω)*cos(Ω) - cos(ω)*sin(Ω)*cos(I) )*y0;
    ecliptic[y] = ( cos(ω)*sin(Ω) + sin(ω)*cos(Ω)*cos(I) )*x0 + ( -sin(ω)*sin(Ω) + cos(ω)*cos(Ω)*cos(I) )*y0;
    ecliptic[z] = (            sin(ω)*sin(I)             )*x0 + (             cos(ω)*sin(I)             )*y0;
    return ecliptic;
}

-(double)KeplersEquation:(double)E M:(double)M e:(double)e{
    double ΔM = M - ( E - (e*180./π) * sin(E*π/180.) );
    double ΔE = ΔM / (1 - e*cos(E*π/180.));
    return E + ΔE;
}

//get location of planet from two times, separated by say a minute
//build a vector which crosses the two points
//interpolate along this path, have the next vector ready
-(void)execute{    
//    glRotatef(23.4, 1, 0, 0);   // align ecliptic plane
    [planetSphere execute];
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
    
    for(int i = OBJECTS-1; i >= 0; i--){
        glPushMatrix();
            glTranslatef(-positions[3*i+x], -positions[3*i+z], -positions[3*i+y]);
            glScalef(10.0, 10.0, 10.0);
            glRotatef(azimuths[i], 0, 1, 0);
            glBindTexture(GL_TEXTURE_2D, ((GLKTextureInfo*)(planetTextures[i])).name);
            if(i == Saturn)
                glVertexPointer(3, GL_FLOAT, 0, rectangleVertices);  // saturn image is 2:1 for the rings
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

-(NSArray*)loadPlanetTextures{
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < 8; i++){
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
