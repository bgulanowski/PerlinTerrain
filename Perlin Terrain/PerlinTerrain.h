//
//  PerlinTerrain.h
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-01-20.
//  Copyright 2011 Bored Astronaut. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <BAFoundation/BANoiseMaker.h>


@class TerrainGenerator, BASceneView, BACameraSetup;

@interface PerlinTerrain : BAScene <NSApplicationDelegate> {
	
	TerrainGenerator *nm;
	IBOutlet BASceneView *sceneView;
	BACameraSetup *cameraSetup;
    BAStage *stage;

	NSWindow *terrainWindow;
	NSWindow *cameraSetupPanel;
}

@property (assign) IBOutlet NSWindow *plotWindow;
@property (assign) IBOutlet NSWindow *terrainWindow;
@property (assign) IBOutlet NSWindow *cameraSetupPanel;

@end
