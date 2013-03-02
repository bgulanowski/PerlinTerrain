//
//  TerrainGenerator.m
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-06.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import "TerrainGenerator.h"


@implementation TerrainGenerator

@synthesize baseNoise, overlayNoise;
@synthesize scale;
@synthesize gradientStart, gradientEnd, useGradient;

- (void)dealloc {
    self.baseNoise = nil;
    self.overlayNoise = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if(self) {
        gradientStart = 0.0f;
        gradientEnd = 32.0f;
        useGradient = YES;
    }
    
    return self;
}

- (id)initWithBaseNose:(id<BANoise>)base overlay:(id<BANoise>)overlay {
    self = [self init];
    if(self) {
        self.baseNoise = base;
        self.overlayNoise = overlay;
    }
    
    return self;
}

- (id)initWithStandardNoise {
    return [self initWithBaseNose:[[[BANoiseMaker alloc] init] autorelease] overlay:[[[BANoiseMaker alloc] init] autorelease]];
}

- (id)initWithRandomNoise {
    return [self initWithBaseNose:[BANoiseMaker randomNoise] overlay:[BANoiseMaker randomNoise]];
}

- (double)evaluateX:(double)x Y:(double)y Z:(double)z {
    return [baseNoise evaluateX:x Y:y Z:z] + [overlayNoise evaluateX:x Y:y Z:z];
}

- (double)blendX:(double)x Y:(double)y Z:(double)z octaves:(unsigned)octave_count persistence:(double)persistence function:(int)func {
    
//    GLfloat accent = __inline_signbitd([overlayNoise blendX:x*0.25f+0.5f Y:y*0.25f+0.5f Z:z*0.25f+0.5f octaves:1 persistence:0.5f function:0]);
    
    double gradient = 0;
    double base = [baseNoise blendX:x*scale.s.w Y:y*scale.s.h Z:z*scale.s.d octaves:octave_count persistence:persistence function:func];

    if(useGradient && gradientStart != gradientEnd) {
        if(y >= gradientEnd)
            gradient = 1.0f;
        else if(y > gradientStart)
            gradient = 2.0f * (y - gradientStart) / (gradientEnd - gradientStart) - 1.0f;
    }
        
    return base - gradient;
}

@end
