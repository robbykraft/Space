//
//  Stars.h
//  Space
//
//  Created by Robby Kraft on 11/10/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "CelestialGroup.h"

@protocol StarsDelegate <NSObject>

@optional
-(void)starsDidLoad;

@end

@interface Stars : CelestialGroup

@property (nonatomic) NSArray *starCatalog;
@property id <StarsDelegate> delegate;
-(void)execute;

@end