//
//  MandelbrotImageView.m
//  Mandelbrot
//
//  Created by Masaki EBATA on 2014/11/10.
//  Copyright (c) 2014年 GMO Payment Gateway, Inc. All rights reserved.
//

#import "MandelbrotView.h"

#import <Accelerate/Accelerate.h>

#import <vector>
#import <stdlib.h>
#import <complex.h>

#define MEMORY_LIMIT 0xff

using namespace std;
@implementation MandelbrotView

double it_result[MEMORY_LIMIT][414 * 414];
- (id)initWithParam:(double)cxmin cxmax:(double)cxmax cymin:(double)cymin cymax:(double)cymax rect:(CGRect)rect delegate:(id<MandelbrotViewDelegate>)delegate{
    self = [super initWithFrame:rect];
    if ( self ) {
        _cxmin = cxmin;
        _cxmax = cxmax;
        _cymin = cymin;
        _cymax = cymax;
        _delegate = delegate;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    int max_iterations = 0xfff;
    int w = self.frame.size.width;
    int h = self.frame.size.height;
    
    vDSP_Length length = w * h;
    vDSP_Stride str = 1;
    
    DSPDoubleSplitComplex c, z;
    c.realp = (double *)calloc(length, sizeof(double));
    c.imagp = (double *)calloc(length, sizeof(double));
    z.realp = (double *)calloc(length, sizeof(double));
    z.imagp = (double *)calloc(length, sizeof(double));
   
    for (int ix = 0; ix < w; ++ix) {
        for (int iy = 0; iy < h; ++iy) {
            c.realp[ix * w + iy] = _cxmin + ix/(w-1.0)*(_cxmax-_cxmin);
            c.imagp[ix * w + iy] = _cymin + iy/(h-1.0)*(_cymax-_cymin);
            
            z.realp[ix * w + iy] = 0;
            z.imagp[ix * w + iy] = 0;
        }
    }
    
    vector<int> iterations(length);
    fill(iterations.begin(), iterations.end(), max_iterations);
    
    NSLog(@"start SIMD");
    for ( int i = 0; i < max_iterations; i += MEMORY_LIMIT ) {
        int limit = max_iterations - i;
        if ( limit > MEMORY_LIMIT ) limit = MEMORY_LIMIT;

        for (int j = 0; j < limit; ++j ) {
            vDSP_zvmulD(&z, str, &z, str, &z, str, length, 1);

            vDSP_zvaddD(&z, str, &c, str, &z, str, length);

            vDSP_zvabsD(&z, str, it_result[j], str, length);
        }

        for (int ix = 0; ix < w; ++ix ) {
            for ( int iy = 0; iy < h; ++iy ) {
                int index = ix * w + iy;
                if ( iterations[index] != max_iterations ) continue;
                
                int l = 0, r = limit - 1;

                int cen = 0;
                while ( (r - l) > 1) {
                    cen = (l + r) / 2;
                    if ( it_result[cen][index] < 2.0f ) {
                        l = cen;
                    }else {
                        r = cen;
                    }
                }

                if ( cen < limit ) {
                    iterations[index] = i + cen < iterations[index] ? i + cen : iterations[index];
                }
            }
        }
    }
   
    NSLog(@"end SIMD");
    for (int ix = 0; ix < w; ++ix ) {
        for ( int iy = 0; iy < h; ++iy ) {
            int it = iterations[ix * w + iy];
            unsigned int rr = ((it & 0xf0) >> 4) * 0xf;
            unsigned int gg = ((it & 0xf0) >> 2) * 0xf;
            unsigned int bb = ((it & 0xff) >> 0) * 0xf;
            
            if ( it >= max_iterations - (max_iterations / 5) ) {
                rr = 0;
                gg = 0;
                bb = 0;
            }
            
            CGContextSetRGBFillColor(context, rr / 256.0f, gg / 256.0f, bb / 256.0f, 1.0f);
            CGContextAddRect(context, CGRectMake(ix, iy, 1.0f, 1.0f));
            CGContextFillPath(context);
        }
        
    }
    
    free( c.realp );
    free( c.imagp );
    free( z.realp );
    free( z.imagp );
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didEndDrawRect:)]) {
        [_delegate didEndDrawRect:self];
    }

}
@end
