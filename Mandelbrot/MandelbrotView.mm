//
//  MandelbrotImageView.m
//  Mandelbrot
//
//  Created by Masaki EBATA on 2014/11/10.
//  Copyright (c) 2014年 GMO Payment Gateway, Inc. All rights reserved.
//

#import "MandelbrotView.h"

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
    double accuracy = 1.0f;
    int w = self.frame.size.width * accuracy;
    int h = self.frame.size.height * accuracy;
    for (int ix = 0; ix < w; ++ix) {
        for (int iy = 0; iy < h; ++iy) {
            complex<double> c(_cxmin + ix/(w-1.0)*(_cxmax-_cxmin), _cymin + iy/(h-1.0)*(_cymax-_cymin));
            complex<double> z = 0;
            unsigned int iterations;
            
            for (iterations = 0; iterations < max_iterations && abs(z) < 2.0; ++iterations)
                z = z*z + c;
            
            unsigned int r = ((iterations & 0xf0) >> 4) * 0xf;
            unsigned int g = ((iterations & 0xf0) >> 2) * 0xf;
            unsigned int b = ((iterations & 0xff) >> 0) * 0xf;
            
            if ( iterations == max_iterations ) {
                r = 0.0f;
                g = 0.0f;
                b = 0.0f;
            }
            CGContextSetRGBFillColor(context, r / 255.0f, g / 255.0f, b / 255.0f, 1.0f);
            CGContextAddRect(context, CGRectMake(ix, iy, 1.0f, 1.0f));
            CGContextFillPath(context);
        }
    }
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didEndDrawRect:)]) {
        [_delegate didEndDrawRect:self];
    }

}
@end
