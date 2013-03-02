//
//  PerlinTerrain.h
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-01-20.
//  Copyright 2011 Bored Astronaut. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <BAFoundation/BANoiseMaker.h>
#import <CorePlot/CorePlot.h>
#import <CorePlot/CPTPlot.h>


@class TerrainGenerator, CPTGraphHostingView, BAVoxelArray, BASceneView, BACameraSetup;

@interface PerlinTerrain : BAScene <NSApplicationDelegate, CPTPlotDataSource> {
	
	TerrainGenerator *nm;
	IBOutlet BASceneView *sceneView;
	BACameraSetup *cameraSetup;
	BAVoxelArray *voxelArray;
    BAStage *stage;

	CPTGraphHostingView *plotView;
    NSWindow *plotWindow;
	NSWindow *terrainWindow;
	NSWindow *cameraSetupPanel;
	
	NSArray *plots;
	
	double offset;
	double inversePersistence;
	unsigned octavesCount;
}

@property (assign) IBOutlet NSWindow *plotWindow;
@property (assign) IBOutlet NSWindow *terrainWindow;
@property (assign) IBOutlet NSWindow *cameraSetupPanel;
@property (assign) IBOutlet CPTGraphHostingView *plotView;

@property (nonatomic) double offset;
@property (nonatomic) double inversePersistence;
@property (nonatomic) unsigned octavesCount;

@end
