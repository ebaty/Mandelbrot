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

using namespace std;
@implementation MandelbrotView

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

    int max_iterations = 0xff;
    int w = self.frame.size.width;
    int h = self.frame.size.height;
    
    vDSP_Length length = w * h;
    vDSP_Stride str = 1;
    
    DSPDoubleSplitComplex c, z;
    c.realp = (double *)calloc(length, sizeof(double));
    c.imagp = (double *)calloc(length, sizeof(double));
    z.realp = (double *)calloc(length, sizeof(double));
    z.imagp = (double *)calloc(length, sizeof(double));
   
    double abs[length];
    
    for (int ix = 0; ix < w; ++ix) {
        for (int iy = 0; iy < h; ++iy) {
            c.realp[ix * iy] = _cxmin + ix/(w-1.0)*(_cxmax-_cxmin);
            c.imagp[ix * iy] = _cymin + iy/(h-1.0)*(_cymax-_cymin);
            
            z.realp[ix * iy] = 0;
            z.imagp[ix * iy] = 0;
        }
    }
    
    double it_result[max_iterations][length];
   
    for (int i = 0; i < max_iterations; ++i ) {
        vDSP_zvmulD(&z, str, &z, str, &z, str, length, 1);
        
        vDSP_zvaddD(&z, str, &c, str, &z, str, 1);
        
        vDSP_zvabsD(&z, str, abs, str, length);
        
        vDSP_vswapD(abs, str, it_result[i], str, length);
    }
    
    for (int ix = 0; ix < w; ++ix ) {
        for ( int iy = 0; iy < h; ++iy ) {
            int index = ix * iy;
            int l = 0, r = max_iterations - 1;
            
            int cen = 0;
            while ( l < r ) {
                cen = (l + r) / 2;
                if ( it_result[cen][index] < 2.0f ) {
                    l = cen;
                }else {
                    r = cen;
                }
            }
            
            unsigned int rr = ((cen & 0xf0) >> 4) * 0xf;
            unsigned int gg = ((cen & 0xf0) >> 2) * 0xf;
            unsigned int bb = ((cen & 0xff) >> 0) * 0xf;
            
            if ( cen == max_iterations - 1 ) {
                rr = 0;
                gg = 0;
                bb = 0;
            }
            
            CGContextSetRGBFillColor(context, rr / 255.0f, gg / 255.0f, bb / 255.0f, 1.0f);
            CGContextAddRect(context, CGRectMake(ix, iy, 1.0f, 1.0f));
            CGContextFillPath(context);
       }
    }
    
   if ( _delegate && [_delegate respondsToSelector:@selector(didEndDrawRect:)]) {
        [_delegate didEndDrawRect:self];
    }

}
@end
