//
//  PerlinTerrain.m
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-01-20.
//  Copyright 2011 Bored Astronaut. All rights reserved.
//

#import "PerlinTerrain.h"

#import <BAScene/BACameraSetup.h>
#import <BAScene/BAScene.h>
#import <BAScene/BASceneView.h>
#import <BAScene/BAStage.h>

#import "TerrainGenerator.h"
#import "BAProp+PerlinTerrain.h"
#import "BAPartition+PerlinTerrain.h"


#define SPACE_DIMENSION 32.f


@interface PerlinTerrain ()

- (void)prepareCamera;

@end


@implementation PerlinTerrain

@synthesize terrainWindow, cameraSetupPanel;

- (void)dealloc {
	[nm release], nm = nil;
	[super dealloc];
}
- (id)init {
	self = [super init];
	if(self) {
        nm = [[TerrainGenerator alloc] initWithRandomNoise];
        [self.context setUndoManager:nil];
	}
	return self;
}


#pragma mark data source

#define INC 1.0f/256.0f
#define COUNT 1024

- (void)awakeFromNib {
	
    BAPartition *rootPartition = [self.context rootPartitionWithDimension:SPACE_DIMENSION];
    BAScalef scale;
    
    scale.s = BAMakeSizef(1.0f/32.0f, 1.0f/48.0f, 1.0f/32.0f);
    nm.scale = scale;
    
//    nm.gradientStart = -31.0f;
//    nm.gradientEnd = 32.0f;
//    nm.useGradient = YES;

    stage = [self.context stage];
    [stage setPartitionRoot:rootPartition];
    [rootPartition recursivelyBuildTerrainWithNoise:nm heightLimit:64.0f];
    [self prepareCamera];
    
    [terrainWindow makeKeyAndOrderFront:nil];
}


#pragma mark NSApplicationDelegate
//- (void)applicationWillFinishLaunching:(NSNotification *)notif {
//    BASceneLogGLInfo();
//}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [sceneView enableDisplayLink];
	[self startUpdates:^BOOL(BAScene *scene, NSTimeInterval interval) {
        
        [stage update:interval];
        [sceneView.camera update:interval];
                
        return NO;
    }];
}


#pragma mark Private

- (void)prepareCamera {
    cameraSetup = [[BACameraSetup alloc] init];
	[cameraSetupPanel setContentSize:[[cameraSetup view] frame].size];
	[cameraSetupPanel setContentView:[cameraSetup view]];	
	cameraSetup.camera = sceneView.camera;

//    sceneView.camera.xLoc  = -8.0f;
    sceneView.camera.yLoc  = 8.f;
    sceneView.camera.zLoc  = 32.0f;
    sceneView.camera.drawDelegate = [self.context stage];

	sceneView.camera.cullingOn = YES;
    
    sceneView.camera.lightLoc = BAMakeLocationf(.5f, .5f, .5f, 1.f);
    
    sceneView.movementRate = 20.0f;
    
    if(USE_NORMALS)
        glShadeModel(GL_FLAT);
}

@end
