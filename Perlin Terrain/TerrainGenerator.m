//
//  TerrainGenerator.m
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-06.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import "TerrainGenerator.h"


static NSString *const PTBaseNoiseEncodingKey = @"baseNoise";
static NSString *const PTOverlayNoiseEncodingKey = @"overlayNoise";
static NSString *const PTGradientStartEncodingKey = @"gradientStart";
static NSString *const PTGradientEndEncodingKey = @"gradientEnd";

@implementation TerrainGenerator

@synthesize baseNoise, overlayNoise;
@synthesize scale;
@synthesize gradientStart, gradientEnd, useGradient;

#pragma mark - NSObject

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

#pragma mark - Initializers

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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.baseNoise forKey:PTBaseNoiseEncodingKey];
	[aCoder encodeObject:self.overlayNoise forKey:PTOverlayNoiseEncodingKey];
	[aCoder encodeFloat:gradientStart forKey:PTGradientStartEncodingKey];
	[aCoder encodeFloat:gradientEnd forKey:PTGradientEndEncodingKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		self.baseNoise = [aDecoder decodeObjectForKey:PTBaseNoiseEncodingKey];
		self.overlayNoise = [aDecoder decodeObjectForKey:PTOverlayNoiseEncodingKey];
		gradientStart = [aDecoder decodeFloatForKey:PTGradientStartEncodingKey];
		gradientEnd = [aDecoder decodeFloatForKey:PTGradientEndEncodingKey];
	}
	return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	TerrainGenerator *copy = [[[self class] alloc] init];
	if (copy) {
		copy.baseNoise = self.baseNoise;
		copy.overlayNoise = self.overlayNoise;
		copy.gradientStart = self.gradientStart;
		copy.gradientEnd = self.gradientEnd;
	}
	return copy;
}

#pragma mark - BANoise

- (double)evaluateX:(double)x Y:(double)y Z:(double)z {
    return [baseNoise evaluateX:x Y:y Z:z] + [overlayNoise evaluateX:x Y:y Z:z];
}

@end
