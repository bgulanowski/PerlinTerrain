//
//  PerlinTerrain.m
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-01-20.
//  Copyright 2011 Bored Astronaut. All rights reserved.
//

#import "PerlinTerrain.h"

#import <BAFoundation/BANoiseMaker.h>

#import <BAScene/BACameraSetup.h>
#import <BAScene/BAGroup.h>
#import <BAScene/BAMesh.h>
#import <BAScene/BAProp.h>
#import <BAScene/BAPrototype.h>
//#import <BAScene/BAResourceStorage.h>
#import <BAScene/BAScene.h>
#import <BAScene/BASceneView.h>
#import <BAScene/BAStage.h>

#import <BAScene/BAVoxelArray.h>

#import <CorePlot/CorePlot.h>

#import "TerrainGenerator.h"
#import "BAProp+PerlinTerrain.h"
#import "BAPartition+PerlinTerrain.h"


#define SPACE_DIMENSION 32.f


@interface CPTXYGraph (NoisePlot)

- (CPTScatterPlot *)addNoisePlotWithName:(id<NSCoding, NSCopying, NSObject>)aName color:(CPTColor *)color;

@end

@implementation CPTXYGraph (NoisePlot)

- (CPTScatterPlot *)addNoisePlotWithName:(id<NSCoding, NSCopying, NSObject>)aName color:(CPTColor *)color {
	
	CPTScatterPlot *plot = [[[CPTScatterPlot alloc] init] autorelease];
    CPTMutableLineStyle *ls = [[plot.dataLineStyle mutableCopy] autorelease];
	
	plot.identifier = aName;
	ls.lineColor = color;
    
    plot.dataLineStyle = ls;
	
	[self addPlot:plot];
	
	return plot;
}

@end


@interface PerlinTerrain ()

- (void)prepareNoiseSample;
- (void)prepareCamera;

@end


@implementation PerlinTerrain

@synthesize plotWindow, terrainWindow, cameraSetupPanel, plotView, offset, inversePersistence, octavesCount;

- (void)dealloc {
	[nm release], nm = nil;
	[plots release], plots = nil;
	[voxelArray release], voxelArray = nil;
	[super dealloc];
}
- (id)init {
	self = [super init];
	if(self) {

        nm = [[TerrainGenerator alloc] initWithRandomNoise];

//		ResourceStorage = [[BAResourceStorage alloc] init];
		 
		octavesCount = 5;
		inversePersistence = 2.0f;
		offset = 1.0f;
        [self.context setUndoManager:nil];
	}
	return self;
}


#pragma mark data source

#define INC 1.0f/256.0f
#define COUNT 1024

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return COUNT;
}

-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	
	double x = (double)index*INC + self.offset;
	
	if(CPTScatterPlotFieldX == fieldEnum)
		return x;

	int function = [(NSNumber *)plot.identifier intValue];

	if(function < 4)
		return [nm blendX:x Y:0 Z:0 octaves:self.octavesCount persistence:1.0f/self.inversePersistence function:function];
	else
		return sin(x);
}

- (void)awakeFromNib {
	
    BAPartition *rootPartition = [BAPartition rootPartitionWithDimension:SPACE_DIMENSION];
    BAScalef scale;
    scale.s = BAMakeSizef(1.0f/32.0f, 1.0f/48.0f, 1.0f/32.0f);

    nm.scale = scale;
    nm.gradientStart = -31.0f;
    nm.gradientEnd = 32.0f;

    [[BAStage stage] setPartitionRoot:rootPartition];
    [rootPartition recursivelyBuildTerrainWithNoise:nm heightLimit:32.0f];    
    [self prepareCamera];
    
    [terrainWindow makeKeyAndOrderFront:nil];
}


#pragma mark NSApplicationDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notif {
//    BASceneLogGLInfo();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [sceneView enableDisplayLink];
	[self startUpdates:^BOOL(BAScene *scene, NSTimeInterval interval) {
        
        [stage update:interval];
        [sceneView.camera update:interval];
                
        return NO;
    }];
}


#pragma mark Accessors
- (void)setInversePersistence:(double)val {
	inversePersistence = val;
	CPTXYGraph *graph = (CPTXYGraph *)plotView.hostedGraph;
	[graph reloadData];
    [graph.defaultPlotSpace scaleToFitPlots:plots];
}

- (void)setOctavesCount:(unsigned)val {
//	if(octavesCount < val)
//		[(CPXYGraph *)plotView.hostedLayer addPlot:[plots objectAtIndex:val-1]];
//	else
//		[(CPXYGraph *)plotView.hostedLayer removePlot:[plots objectAtIndex:val]];
	octavesCount = val;
	[(CPTXYGraph *)plotView.hostedGraph reloadData];	
}

- (void)setOffset:(double)val {
	
	offset = val;

	CPTXYGraph *graph = (CPTXYGraph *)plotView.hostedGraph;
	
	[graph reloadData];
    [graph.defaultPlotSpace scaleToFitPlots:plots];
}


#pragma mark Private

- (void)prepareNoiseSample {
    
	CGRect rect = CGRectMake(0, 0, 256, 256);
	CPTXYGraph *graph = [[[CPTXYGraph alloc] initWithFrame:rect
											  xScaleType:CPTScaleTypeLinear
											  yScaleType:CPTScaleTypeLinear] autorelease];
	
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
	
	plots = [[NSArray arrayWithObjects:
			  [graph addNoisePlotWithName:[NSNumber numberWithInt:0] color:[CPTColor blackColor]],
			  [graph addNoisePlotWithName:[NSNumber numberWithInt:3] color:[CPTColor purpleColor]],
//			  [graph addNoisePlotWithName:[NSNumber numberWithInt:4] color:[CPTColor blueColor]],
//			  [graph addNoisePlotWithName:[NSNumber numberWithInt:3] color:[CPTColor greenColor]],
//			  [graph addNoisePlotWithName:@"5" color:[CPTColor yellowColor]],
			  nil] retain];
	[plots enumerateObjectsUsingBlock:^(CPTPlot *obj, NSUInteger idx, BOOL *stop) { [obj setDataSource:self]; }];
    
	graph.plotAreaFrame.paddingLeft = 20.0;
	
	CPTXYPlotSpace *plotSpace = (id)graph.defaultPlotSpace;
    
    [plotSpace scaleToFitPlots:plots];
//	[plotSpace setPlotRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.25f)
//														length:CPDecimalFromDouble(2.5f)] forCoordinate:CPTCoordinateY];
	plotView.hostedGraph = graph;
}

- (void)prepareCamera {
    cameraSetup = [[BACameraSetup alloc] init];
	[cameraSetupPanel setContentSize:[[cameraSetup view] frame].size];
	[cameraSetupPanel setContentView:[cameraSetup view]];	
	cameraSetup.camera = sceneView.camera;

    sceneView.camera.xLoc  = - 10.0f;
    sceneView.camera.yLoc  = 48.f * 0.5f;
    sceneView.camera.zLoc  = - 10.0f;

	sceneView.camera.cullingOn = YES;
    
    sceneView.camera.lightLoc = BAMakeLocationf(.5f, .5f, .5f, 1.f);
    
    sceneView.movementRate = 20.0f;
    
    if(USE_NORMALS)
        glShadeModel(GL_FLAT);
}

@end
