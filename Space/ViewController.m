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
    Celestial *celestial;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    celestial = [[Celestial alloc] init];
    [celestial setOrientToDevice:YES];
    [celestial setPinchZoom:NO];
    [self setView:celestial];
    [self performSelectorInBackground:@selector(loadStars:) withObject:@"hyg4.csv"];
}

-(void)loadStars:(NSString*)catalog{
    NSString *path = [[NSBundle mainBundle] pathForResource:catalog ofType:NULL];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfCSVFile:path];
    [array removeObjectAtIndex:0];  // database has one line of header
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
    [[celestial stars] setStarCatalog:stars];
}

// OpenGL redraw screen
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [celestial execute];
}

@end