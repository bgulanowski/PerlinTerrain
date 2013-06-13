//
//  BAProp+PerlinTerrain.h
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-04.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import <BAScene/BAScene.h>

#import <BAScene/BAProp.h>


#define USE_NORMALS 1

@class BAVoxelArray;

@interface NSManagedObjectContext (PerlinTerrain)
- (BAProp *)terrainPropWithRegion:(BARegionf)region voxels:(BAVoxelArray *)voxels;
@end
