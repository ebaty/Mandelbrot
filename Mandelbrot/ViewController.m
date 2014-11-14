//
//  ViewController.m
//  Mandelbrot
//
//  Created by Masaki EBATA on 2014/11/10.
//  Copyright (c) 2014年 GMO Payment Gateway, Inc. All rights reserved.
//

#import "ViewController.h"
#import "MandelbrotView.h"

@interface ViewController () <UIScrollViewDelegate, MandelbrotViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) MandelbrotView *mandelbrotView;
@property (nonatomic) CGPoint pinchPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    _mandelbrotView = [[MandelbrotView alloc] initWithParam:-2.0f cxmax:1.0f cymin:-1.5f cymax:1.5f rect:rect delegate:self];
    
    [_scrollView addSubview:_mandelbrotView];
    
    [_scrollView.pinchGestureRecognizer addTarget:self action:@selector(checkPoint)];
}

- (void)viewDidLayoutSubviews {
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
}

- (void)checkPoint {
    _pinchPoint = [_scrollView.pinchGestureRecognizer locationInView:_mandelbrotView];
}

#pragma mark - UIScrollView delegate.
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _mandelbrotView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ( scale > 2.0f ) {
        _scrollView.userInteractionEnabled = NO;
        
        double width  = _mandelbrotView.cxmax - _mandelbrotView.cxmin;
        double height = _mandelbrotView.cymax - _mandelbrotView.cymin;
        double x = (_pinchPoint.x / [UIScreen mainScreen].bounds.size.width)  * width  + _mandelbrotView.cxmin;
        double y = (_pinchPoint.y / [UIScreen mainScreen].bounds.size.width)  * height + _mandelbrotView.cymin;
        NSLog(@"%lf %lf", x, y);
        
        double cxmin = x - (width  / (2 * scale));
        double cxmax = x + (width  / (2 * scale));
        double cymin = y - (height / (2 * scale));
        double cymax = y + (height / (2 * scale));
        
        NSLog(@"%lf %lf %lf %lf", cxmin, cxmax, cymin, cymax);
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
        MandelbrotView *newMandelbrot = [[MandelbrotView alloc] initWithParam:cxmin cxmax:cxmax cymin:cymin cymax:cymax rect:rect delegate:self];
        
        [_mandelbrotView removeFromSuperview];
        
        [scrollView addSubview:newMandelbrot];
        _mandelbrotView = newMandelbrot;
        
        _scrollView.zoomScale = 1.0f;
        _scrollView.userInteractionEnabled = YES;
    }
}

- (void)didEndDrawRect:(MandelbrotView *)view {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
@end
