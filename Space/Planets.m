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

#define X_VALUE 0
#define Y_VALUE 1
#define Z_VALUE 2

//                                  a               e                I                 L             long.peri.       long.node.
//                              AU, AU/Cy      rad, rad/Cy      deg, deg/Cy       deg, deg/Cy       deg, deg/Cy      deg, deg/Cy
static double eph_mercury0[] = {0.38709927,      0.20563593,      7.00497902,      252.25032350,     77.45779628,     48.33076593 };
static double eph_mercuryI[] = {0.00000037,      0.00001906,     -0.00594749,   149472.67411175,      0.16047689,     -0.12534081 };
static double eph_venus0[] =   {0.72333566,      0.00677672,      3.39467605,      181.97909950,    131.60246718,     76.67984255 };
static double eph_venusI[] =   {0.00000390,     -0.00004107,     -0.00078890,    58517.81538729,      0.00268329,     -0.27769418 };
static double eph_earth0[] =   {1.00000261,      0.01671123,     -0.00001531,      100.46457166,    102.93768193,      0.0 };  //earth moon barycenter
static double eph_earthI[] =   {0.00000562,     -0.00004392,     -0.01294668,    35999.37244981,      0.32327364,      0.0 };
static double eph_mars0[] =    {1.52371034,      0.09339410,      1.84969142,       -4.55343205,    -23.94362959,     49.55953891 };
static double eph_marsI[] =    {0.00001847,      0.00007882,     -0.00813131,    19140.30268499,      0.44441088,     -0.29257343 };
static double eph_jupiter0[] = {5.20288700,      0.04838624,      1.30439695,       34.39644051,     14.72847983,    100.47390909 };
static double eph_jupiterI[] = {-0.00011607,     -0.00013253,     -0.00183714,     3034.74612775,      0.21252668,      0.20469106 };
static double eph_saturn0[] =  {9.53667594,      0.05386179,      2.48599187,       49.95424423,     92.59887831,    113.66242448 };
static double eph_saturnI[] =  {-0.00125060,     -0.00050991,      0.00193609,     1222.49362201,     -0.41897216,     -0.28867794 };
static double eph_uranus0[] =  {19.18916464,      0.04725744,      0.77263783,      313.23810451,    170.95427630,     74.01692503 };
static double eph_uranusI[] =  {-0.00196176,     -0.00004397,     -0.00242939,      428.48202785,      0.40805281,      0.04240589 };
static double eph_neptune0[] = {30.06992276,      0.00859048,      1.77004347,      -55.12002969,     44.96476227,    131.78422574 };
static double eph_neptuneI[] = {0.00026291,      0.00005105,      0.00035372,      218.45945325,     -0.32241464,     -0.00508664 };
static double eph_pluto0[] =   {39.48211675,      0.24882730,     17.14001206,      238.92903833,    224.06891629,    110.30393684 };
static double eph_plutoI[] =   {-0.00031596,      0.00005170,      0.00004818,      145.20780515,     -0.04062942,     -0.01183482 };

typedef enum{
    Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune
}
Planet;

@implementation Planets{
    Sphere *planetSphere;
    GLfloat *positions;
    NSArray *names;
    NSArray *planetTextures;
    float J2000;
}

@synthesize delegate;

-(id) init{
    self = [super init];
    if (self) {     
        planetSphere = [[Sphere alloc] init:SLICES slices:SLICES radius:9999.0 squash:1.0 textureFile:@"equatorial_line.png"];
        names = @[@"Mercury", @"Venus", @"Earth", @"Mars", @"Jupiter", @"Saturn", @"Uranus", @"Neptune"];
        planetTextures = [self loadPlanetTextures];
        J2000 = .128767;  // mid Nov. 2013
        NSArray *earthPos = [self locationOfPlanet:Earth Time:.128767];
        NSLog(@"Earth: (%@, %@, %@)",[earthPos objectAtIndex:0], [earthPos objectAtIndex:1], [earthPos objectAtIndex:2]);
        NSLog(@"Sqrt: %f", sqrt([[earthPos objectAtIndex:0] floatValue] * [[earthPos objectAtIndex:0] floatValue] +
                                [[earthPos objectAtIndex:1] floatValue] * [[earthPos objectAtIndex:1] floatValue] +
                                [[earthPos objectAtIndex:2] floatValue] * [[earthPos objectAtIndex:2] floatValue]));
        NSArray *marsPos = [self locationOfPlanet:Mars Time:.128767];
        NSLog(@"Mars: (%@, %@, %@)",[marsPos objectAtIndex:0], [marsPos objectAtIndex:1], [marsPos objectAtIndex:2]);
        NSLog(@"Sqrt: %f", sqrt([[marsPos objectAtIndex:0] floatValue] * [[marsPos objectAtIndex:0] floatValue] +
                                [[marsPos objectAtIndex:1] floatValue] * [[marsPos objectAtIndex:1] floatValue] +
                                [[marsPos objectAtIndex:2] floatValue] * [[marsPos objectAtIndex:2] floatValue]));
        NSArray *jupiterPos = [self locationOfPlanet:Jupiter Time:.128767];
        NSLog(@"Jupiter: (%@, %@, %@)",[jupiterPos objectAtIndex:0], [jupiterPos objectAtIndex:1], [jupiterPos objectAtIndex:2]);
        NSLog(@"Sqrt: %f", sqrt([[jupiterPos objectAtIndex:0] floatValue] * [[jupiterPos objectAtIndex:0] floatValue] +
                                [[jupiterPos objectAtIndex:1] floatValue] * [[jupiterPos objectAtIndex:1] floatValue] +
                                [[jupiterPos objectAtIndex:2] floatValue] * [[jupiterPos objectAtIndex:2] floatValue]));
    }
    return self;
}

-(void)setDistantPlanets:(NSArray *)distantPlanets{
    _distantPlanets = distantPlanets;
}

// today's date. progression through 2013 320 / 365  (dec: .8767)
// + 12 years since 2000
// .12 + .008767   in centuries
// .128767

// http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf

-(int)factorial:(int)input{
    int result = 1;
    if(input<=0) return 0;
    for(int i = 1; i <= input; i++)
        result *= i;
    return result;
}

-(void)seriesExpansionSineOf:(double)x{
    double answer = 0.0;
    double iteration;
    for(int i = 1; i < 10; i++){
        iteration = powf(x, i*2-1) / [self factorial:i*2-1];
        if(i%2 == 0)
            iteration = -iteration;
        answer += iteration;
        NSLog(@"%f (%f)",answer, iteration);
    }
}

-(NSArray*)locationOfPlanet:(Planet)planet Time:(float)time{
    
    float deg2rad = M_PI/180.0;
    
// location of planet in the J2000 ecliptic plane, with the X-axis aligned toward the equinox
    double *ephemeris0, *ephemerisI;
    if(planet == Mercury) {ephemeris0 = eph_mercury0; ephemerisI = eph_mercuryI; }
    else if(planet == Venus) {ephemeris0 = eph_venus0; ephemerisI = eph_venusI; }
    else if(planet == Earth) {ephemeris0 = eph_earth0; ephemerisI = eph_earthI; }
    else if(planet == Mars) {ephemeris0 = eph_mars0; ephemerisI = eph_marsI; }
    else if(planet == Jupiter) {ephemeris0 = eph_jupiter0; ephemerisI = eph_jupiterI; }
    else if(planet == Saturn) {ephemeris0 = eph_saturn0; ephemerisI = eph_saturnI; }
    else if(planet == Uranus) {ephemeris0 = eph_uranus0; ephemerisI = eph_uranusI; }
    else if(planet == Neptune) {ephemeris0 = eph_neptune0; ephemerisI = eph_neptuneI; }
    else {ephemeris0 = eph_pluto0; ephemerisI = eph_plutoI; }
    
//    double semi_major_axis;
//    double eccentricity;
//    double inclination;
//    double mean_longitude;
//    double longitude_of_periapsis;
//    double longitude_of_the_ascending_node;
    
    double a = ephemeris0[0] + ephemerisI[0]*time;
    double e = ephemeris0[1] + ephemerisI[1]*time;
    double I = ephemeris0[2] + ephemerisI[2]*time;
    double L = ephemeris0[3] + ephemerisI[3]*time;
    double longPeri = ephemeris0[4] + ephemerisI[4]*time;
    double longNode = ephemeris0[5] + ephemerisI[5]*time;
    
    double argPeri = longPeri - longNode;
    double meanAnomaly = L - longPeri;// + bT^2 + c cos(fT) + s sin(fT);  //extra stuff for Jupiter-Pluto
    while(meanAnomaly > 180) meanAnomaly-=360;  // in degrees
    double eccentricAnomaly = 0; // fuck. inverse series. later.
    
    // solve kepler's equation
    
    double e_in_degrees = e*(180/M_PI);
    
    double eccentricAnomaly0 = meanAnomaly + e_in_degrees * sin(meanAnomaly*deg2rad);  // in degrees
    NSLog(@"eccentric anomaly 0: %f",eccentricAnomaly0);
    // the loop
    eccentricAnomaly = eccentricAnomaly0;
    for(int i = 0; i < 5; i++){
        eccentricAnomaly = [self iterateKeplersEquation:eccentricAnomaly MeanAnomaly:meanAnomaly Eccentricity:e];
    }
    // end loop
    
    double x0 = a*cos(eccentricAnomaly-e);
    double y0 = a*sqrt(1-e*e)*sin(eccentricAnomaly);
//    double z0 = 0.0;  // true. but unused.
    
    double x = (GLfloat)( ( cos(argPeri*deg2rad)*cos(longNode*deg2rad) - sin(argPeri*deg2rad)*sin(longNode*deg2rad)*cos(I*deg2rad) )*x0 + ( -sin(argPeri*deg2rad)*cos(longNode*deg2rad) - cos(argPeri*deg2rad)*sin(longNode*deg2rad)*cos(I*deg2rad) )*y0 );
    double y = (GLfloat)( ( cos(argPeri*deg2rad)*sin(longNode*deg2rad) + sin(argPeri*deg2rad)*cos(longNode*deg2rad)*cos(I*deg2rad) )*x0 + ( -sin(argPeri*deg2rad)*sin(longNode*deg2rad) - cos(argPeri*deg2rad)*cos(longNode*deg2rad)*cos(I*deg2rad) )*y0 );
    double z = (GLfloat)( (sin(argPeri*deg2rad)*sin(I*deg2rad)) * x0 + (cos(argPeri*deg2rad)*sin(I*deg2rad)) * y0 );
    return @[ [NSNumber numberWithDouble:x], [NSNumber numberWithDouble:y], [NSNumber numberWithDouble:z]];
}

-(double)iterateKeplersEquation:(double)eccentricAnomaly0 MeanAnomaly:(double)meanAnomaly Eccentricity:(double)e{
    double e_in_degrees = e*(180/M_PI);
    double deltaM = meanAnomaly - eccentricAnomaly0 - e_in_degrees * sin(eccentricAnomaly0*M_PI/180.0);
    double deltaE = deltaM / (1 - e*cos(eccentricAnomaly0*M_PI/180.0));
    double newEccentricAnomaly = eccentricAnomaly0 + deltaE;
    NSLog(@"New Eccentric Anomaly: %f",newEccentricAnomaly);
    return newEccentricAnomaly;
}



//get location of planet from two times, separated by say a minute
//build a vector which crosses the two points
//interpolate along this path, have the next vector ready



-(void)execute{    
//    glRotatef(23.4, 1, 0, 0);   // align ecliptic plane
    [planetSphere execute];
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
