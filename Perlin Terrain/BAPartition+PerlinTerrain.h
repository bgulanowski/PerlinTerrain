//
//  BAPartition+PerlinTerrain.h
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-04.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import <BAScene/BAScene.h>

@class TerrainGenerator;

@interface BAPartition (PerlinTerrain)
- (void)buildTerrainWithNoise:(TerrainGenerator *)tg;
- (void)recursivelyBuildTerrainWithNoise:(TerrainGenerator *)tg heightLimit:(GLfloat)heightLimit;
@end
