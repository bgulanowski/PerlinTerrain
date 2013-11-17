//
//  TerrainGenerator.h
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-06.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import <BAScene/BASceneTypes.h>
#import <BAFoundation/BANoiseMaker.h>


@class BANoiseMaker;

@interface TerrainGenerator : NSObject<BANoise> {
    
    BANoiseMaker *baseNoise;
    BANoiseMaker *overlayNoise;
    
    BAScalef scale;
    
    GLfloat gradientStart;
    GLfloat gradientEnd;
    BOOL useGradient;
}

@property (nonatomic, copy) BANoiseMaker *baseNoise;
@property (nonatomic, copy) BANoiseMaker *overlayNoise;
@property (nonatomic) BAScalef scale;
@property (nonatomic) GLfloat gradientStart;
@property (nonatomic) GLfloat gradientEnd;
@property (nonatomic) BOOL useGradient;

- (id)initWithBaseNose:(id<BANoise>)base overlay:(id<BANoise>)overlay;
- (id)initWithStandardNoise;
- (id)initWithRandomNoise;

@end
