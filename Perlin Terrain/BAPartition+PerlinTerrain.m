//
//  BAPartition+PerlinTerrain.m
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-04.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import "BAPartition+PerlinTerrain.h"
#import "BAProp+PerlinTerrain.h"
#import "TerrainGenerator.h"

#import <BAFoundation/NSManagedObjectContext+BAAdditions.h>

#import <BAScene/BAVoxelArray.h>

#import <BAFoundation/NSManagedObjectContext+BAAdditions.h>


@implementation BAPartition (PerlinTerrain)

-  (void)buildTerrainWithNoise:(TerrainGenerator *)tg {
    
    static BAScalef normalScale = {{ 1.0f/16.0f, 1.0f/16.0f, 1.0f/16.0f }};
    BAVoxelArray *voxels = [[BAVoxelArray voxelArrayInRegion:self.region scale:normalScale precision:4 noise:tg] voxelArrayByRemovingHiddenBits];
    BAProp *prop = [self.managedObjectContext terrainPropWithRegion:self.region voxels:voxels];
    
    [self.userData setObject:voxels forKey:@"Voxels"];
    [self addProp:prop];
}

- (void)recursivelyBuildTerrainWithNoise:(TerrainGenerator *)tg heightLimit:(GLfloat)heightLimit {
    
    BOOL hasChildren = NO;
    
    [self subdivide];
    
    for(BAPartition *child in [self children]) {
        hasChildren = YES;
        if(BAMinYf(child.region) < heightLimit && BAMaxYf(child.region) > -heightLimit)
            [child recursivelyBuildTerrainWithNoise:tg heightLimit:heightLimit];
    }
    
    if(!hasChildren && BAMinYf(self.region) < heightLimit && BAMaxYf(self.region) > -heightLimit)
        [self buildTerrainWithNoise:tg];
}

@end
