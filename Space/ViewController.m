//
//  ViewController.m
//  Space
//
//  Created by Robby Kraft on 11/2/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//
/*
 StarID,
 Hip,
 HD,
 HR,
 Gliese,
 BayerFlamsteed,
 ProperName,
 RA,
 Dec,
 Distance,
 Mag,
 AbsMag,
 Spectrum,
 ColorIndex
 */

#import "ViewController.h"
#import "PanoramaView.h"
#import "PlanetariumView.h"

@interface ViewController (){
    PanoramaView *panoramaView;
    PlanetariumView *planetariumView;
    NSMutableArray *stars;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [panoramaView setTexture:@"equirectangular-projection-lines.png"];
    [panoramaView setCelestialSphere:NO];  // spinning stars background
    [panoramaView setOrientToDevice:YES];  // initialize device orientation sensors
    [panoramaView setPinchZoom:YES];  // activate touch gesture, alters field of view
    [panoramaView setLoadingDelegate:self];
    [self setView:panoramaView];
    planetariumView = nil;
    [self performSelectorInBackground:@selector(getStars) withObject:nil];

    
}

-(void)starsDidLoad{
    NSLog(@"StarsDidLoad");
//    [self enterPlanetarium];
}

-(void)enterPlanetarium{
    panoramaView = nil;
    planetariumView = [[PlanetariumView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [planetariumView setTexture:@"equirectangular-planetarium-lines.png"];
    [planetariumView setOrientToDevice:YES];  // initialize device orientation sensors
    [planetariumView setPinchZoom:YES];  // activate touch gesture, alters field of view
    [planetariumView setTimeSpeed:.00001];
    [self setView:planetariumView];
}

-(void)getStars{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hygtiny.csv" ofType:NULL];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfCSVFile:path];
    NSLog(@"%d",(int)array.count);
    stars = [NSMutableArray array];
    for(NSArray *a in array){
        NSMutableDictionary *star = [NSMutableDictionary dictionary];
        [star setObject:a[7] forKey:@"RA"];
        [star setObject:a[8] forKey:@"Dec"];
        [star setObject:a[9] forKey:@"Distance"];
        [star setObject:a[10] forKey:@"Mag"];
        [stars addObject:star];
    }
    [stars removeObjectAtIndex:0];
    NSMutableArray *condensed = [NSMutableArray array];
    for(int i = 1; i < array.count; i++)
        if(i%10 == 0)
            [condensed addObject:stars[i]];
    [panoramaView setStars:stars];
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    if(panoramaView != nil)
        [panoramaView execute];
    if(planetariumView != nil)
        [planetariumView execute];
}

@end