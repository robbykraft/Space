//
//  ViewController.m
//  Space
//
//  Created by Robby Kraft on 11/2/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ViewController.h"
#import "Celestial.h"

@interface ViewController (){
    Celestial *celestialView;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self enterPlanetarium];
    [self performSelectorInBackground:@selector(getStars) withObject:nil];
}

-(void)enterPlanetarium{
    celestialView = [[Celestial alloc] init];
    [celestialView setTexture:@"equirectangular-projection-lines.png"];
    [celestialView setCelestialSphere:YES];
    [celestialView setOrientToDevice:YES];
    [celestialView setPinchZoom:YES];
    [celestialView setLoadingDelegate:self];
    [self setView:celestialView];
}

-(void)getStars{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hyg4.csv" ofType:NULL];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfCSVFile:path];
    [array removeObjectAtIndex:0];
    NSLog(@"%d stars loaded",(int)array.count);
    NSMutableArray *stars = [NSMutableArray array];
    for(NSArray *a in array){
        NSMutableDictionary *star = [NSMutableDictionary dictionary];
        // StarID, Hip, HD, HR, Gliese, BayerFlamsteed, ProperName, RA, Dec, Distance, Mag, AbsMag, Spectrum, ColorIndex
        [star setObject:a[7] forKey:@"RA"];
        [star setObject:a[8] forKey:@"Dec"];
        [star setObject:a[9] forKey:@"Distance"];
        [star setObject:a[10] forKey:@"Mag"];
        [stars addObject:star];
    }
    [celestialView setStars:stars];
}
-(void)starsDidLoad{
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [celestialView execute];
}

@end