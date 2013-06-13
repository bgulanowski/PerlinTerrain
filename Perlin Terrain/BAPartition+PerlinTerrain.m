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
    
    static BAScalef normalScale = {{ 1.0f, 1.0f, 1.0f }};
    BAVoxelArray *voxels = [[BAVoxelArray voxelArrayInRegion:self.region scale:normalScale precision:4 noise:tg] voxelArrayByRemovingHiddenBits];
    
    [self.userData setObject:voxels forKey:@"Voxels"];
    [self addProp:[self.managedObjectContext terrainPropWithRegion:self.region voxels:voxels]];
}

- (void)recursivelyBuildTerrainWithNoise:(TerrainGenerator *)tg heightLimit:(GLfloat)heightLimit {
    
    static NSPredicate *filter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSEntityDescription *partitionEntity = [NSEntityDescription entityForName:@"Partition" inManagedObjectContext:BAActiveContext];
        
        filter = [NSPredicate predicateWithFormat:@"entity == %@", partitionEntity];
    });
    
    BOOL hasChildren = NO;
    
    [self subdivide];
    
    for(BAPartition *child in [[self subgroups] filteredSetUsingPredicate:filter]) {
        hasChildren = YES;
        if(BAMinYf(child.region) < heightLimit && BAMaxYf(child.region) > -heightLimit)
            [child recursivelyBuildTerrainWithNoise:tg heightLimit:heightLimit];
    }
    
    if(!hasChildren && BAMinYf(self.region) < heightLimit && BAMaxYf(self.region) > -heightLimit)
        [self buildTerrainWithNoise:tg];
}

@end
