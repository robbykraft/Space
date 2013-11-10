//
//  ViewController.h
//  Space
//
//  Created by Robby Kraft on 11/2/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "CHCSVParser.h"
#import "Celestial.h"

@interface ViewController : GLKViewController <CHCSVParserDelegate, LoadingDelegate>

@end