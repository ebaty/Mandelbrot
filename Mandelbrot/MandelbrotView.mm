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

@interface MandelbrotView ()

@property (nonatomic) double cxmin;
@property (nonatomic) double cxmax;
@property (nonatomic) double cymin;
@property (nonatomic) double cymax;

@end

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
            
            int r = ((iterations & 0xf0) >> 2) * 0xf;
            int g = ((iterations & 0xf0) >> 1) * 0xf;
            int b = ((iterations & 0x0f) >> 0) * 0xf;
            
            CGContextSetRGBFillColor(context, r / 255.0f, g / 255.0f, b / 255.0f, 1.0f);
            CGContextAddRect(context, CGRectMake(ix / accuracy, iy / accuracy, 1.0f / accuracy, 1.0f / accuracy));
            CGContextFillPath(context);
        }
    }
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didEndDrawRect:)]) {
        [_delegate didEndDrawRect:self];
    }
}
@end
