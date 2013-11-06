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

@interface ViewController (){
    PanoramaView *panoramaView;
    NSMutableArray *stars;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
//    [self getStars];
    
    panoramaView = [[PanoramaView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [panoramaView setTexture:@"equirectangular-projection-lines.png"];
//    [panoramaView setTexture:@"park_2048.png"];
    [panoramaView setCelestialSphere:YES];  // spinning stars background
    [panoramaView setOrientToDevice:YES];  // initialize device orientation sensors
    [panoramaView setPinchZoom:YES];  // activate touch gesture, alters field of view
    [self setView:panoramaView];
    
    [self performSelectorInBackground:@selector(getStars) withObject:nil];
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
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [panoramaView execute];
}

@end