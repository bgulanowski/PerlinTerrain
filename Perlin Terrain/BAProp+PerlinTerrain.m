//
//  BAProp+PerlinTerrain.m
//  Perlin Terrain
//
//  Created by Brent Gulanowski on 11-10-04.
//  Copyright (c) 2011 Bored Astronaut. All rights reserved.
//

#import "BAProp+PerlinTerrain.h"

#import <BAScene/BAVoxelArray.h>
#import <BAScene/BAResource.h>

static inline BAQuad makeQuad(BAPointf p1, BAPointf p2, BAPointf p3, BAPointf p4) {
    
    BAQuad quad;
    
    quad.a = p1; quad.b = p2; quad.c = p3; quad.d = p4;
    
    return quad;
}

static inline BAQuad offsetQuad(BAQuad q, GLfloat x, GLfloat y, GLfloat z) {
    
    BAQuad quad = q;
    
    for(BAPointf *p=&quad.a; p<=&quad.d; ++p) {
        p->x += x;
        p->y += y;
        p->z += z;
    }
    
    return quad;
};

static inline void copyQuadAndNormalData(BAQuad quad, BAPointf normal, GLfloat *buffer) {
    
#if USE_NORMALS
    GLfloat *p = (GLfloat *)&quad;
    GLfloat *n = (GLfloat *)&normal;
    
    for(NSUInteger i=0; i<4; ++i) {
        for(NSUInteger j=0; j<3; ++j)
            buffer[i*6+j] = (GLfloat)p[i*3+j];
        for(NSUInteger j=0; j<3; ++j)        
            buffer[i*6+3+j] = (GLfloat)n[j];
    }
    
#else
    GLfloat *p = (GLfloat *)&quad;
    
    for(NSUInteger i=0; i<4; ++i) {
        for(NSUInteger j=0; j<3; ++j)
            buffer[i*3+j] = (GLfloat)p[i*3+j];
    }
#endif
}

#define copyVerts(Q, X, Y, Z, N, B) copyQuadAndNormalData(offsetQuad((Q), (X), (Y), (Z)), (N), (B))

@implementation NSManagedObjectContext (PerlinTerrain)

- (BAProp *)terrainPropWithRegion:(BARegionf)region voxels:(BAVoxelArray *)voxels {
    
    static BAQuad lx, rx, ly, ry, lz, rz;
    static BAPointf lxn, rxn, lyn, ryn, lzn, rzn;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lx = makeQuad(BAMakePointf(0, 0, 0), BAMakePointf(0, 0, 1), BAMakePointf(0, 1, 1), BAMakePointf(0, 1, 0));
        rx = makeQuad(BAMakePointf(1, 0, 0), BAMakePointf(1, 1, 0), BAMakePointf(1, 1, 1), BAMakePointf(1, 0, 1));
        ly = makeQuad(BAMakePointf(0, 0, 0), BAMakePointf(1, 0, 0), BAMakePointf(1, 0, 1), BAMakePointf(0, 0, 1));
        ry = makeQuad(BAMakePointf(0, 1, 0), BAMakePointf(0, 1, 1), BAMakePointf(1, 1, 1), BAMakePointf(1, 1, 0));
        lz = makeQuad(BAMakePointf(0, 0, 0), BAMakePointf(0, 1, 0), BAMakePointf(1, 1, 0), BAMakePointf(1, 0, 0));
        rz = makeQuad(BAMakePointf(0, 0, 1), BAMakePointf(1, 0, 1), BAMakePointf(1, 1, 1), BAMakePointf(0, 1, 1));
        
        lxn = BAMakePointf(-1.0f, 0, 0);
        rxn = BAMakePointf( 1.0f, 0, 0);
        lyn = BAMakePointf(0, -1.0f, 0);
        ryn = BAMakePointf(0,  1.0f, 0);
        lzn = BAMakePointf(0, 0, -1.0f);
        rzn = BAMakePointf(0, 0,  1.0f);
    });
    
    const NSUInteger elementsInPoint = 3 /*vertices*/ + (USE_NORMALS == 1 ? 3 : 0 /* normals*/);
    const NSUInteger elementsInQuad  = 4 * elementsInPoint;
    const NSUInteger elementsInVoxel = 6 * elementsInQuad;
    const NSUInteger xy = (NSUInteger)(region.volume.s.w * region.volume.s.h);
        
    // we don't actually need this many; we will count actual elements
    GLfloat *verts = malloc([voxels count] * elementsInVoxel * sizeof(GLfloat)), *nextVert = verts;
    NSUInteger i=0;
    
    NSAssert(verts, @"malloc failed");
    
    for(GLfloat z=0; z<region.volume.s.d; ++z) {
        for(GLfloat y=0; y<region.volume.s.h; ++y) {
            for(GLfloat x=0; x<region.volume.s.w; ++x) {
                
                if([voxels bit:i]) {
                    if(0==z || ![voxels bit:i-xy]) {
                        copyVerts(lz, x, y, z, lzn, nextVert);
                        nextVert+=elementsInQuad;
                    }
                    if(region.volume.s.d-1==z || ![voxels bit:i+xy]) {
                        copyVerts(rz, x, y, z, rzn, nextVert);
                        nextVert+=elementsInQuad;
                    }
                    if(0==y || ![voxels bit:i-region.volume.s.w]) {
                        copyVerts(ly, x, y, z, lyn, nextVert);
                        nextVert+=elementsInQuad;
                    }
                    if(region.volume.s.h-1==y || ![voxels bit:i+region.volume.s.w]) {
                        copyVerts(ry, x, y, z, ryn, nextVert);
                        nextVert+=elementsInQuad;
                    }
                    if(0==x || ![voxels bit:i-1]) {
                        copyVerts(lx, x, y, z, lxn, nextVert);
                        nextVert+=elementsInQuad;
                    }
                    if(region.volume.s.w-1==x || ![voxels bit:i+1]) {
                        copyVerts(rx, x, y, z, rxn, nextVert);
                        nextVert+=elementsInQuad;
                    }
                }
                ++i;
            }
        }
    }
    
    NSUInteger count = nextVert-verts;
    BAMesh *mesh = [self meshWithName:nil];
    NSData *vertexData = [NSData dataWithBytesNoCopy:verts length:count*sizeof(GLfloat) freeWhenDone:NO];
    
    mesh.hasNormalsValue = USE_NORMALS;
    mesh.typeValue = GL_QUADS;
	[mesh addResourcesObject:[self resourceWithType:0 data:vertexData]];
    [mesh prepareVertexBuffer]; // vertex resource data is discarded
	
    free(verts);
    
//    NSLog(@"Made %lu quads for %lu voxels (savings of %lu)", count/elementsInQuad, voxels.count, voxels.count * (elementsInVoxel/elementsInQuad) - count/elementsInQuad);
    
    
    BAPrototype *pt = [self prototypeWithName:nil mesh:mesh];
    BAProp *prop = [self propWithName:nil prototype:pt];
    
    prop.color = [self randomWarmColor];
    prop.transform = [self translationWithX:region.origin.p.x y:region.origin.p.y z:region.origin.p.z];
    
    return prop;
}

@end
