//
//  ViewController.m
//  Mandelbrot
//
//  Created by Masaki EBATA on 2014/11/10.
//  Copyright (c) 2014年 GMO Payment Gateway, Inc. All rights reserved.
//

#import "ViewController.h"
#import "MandelbrotView.h"
#import "UIView+Indicator.h"

@interface ViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) MandelbrotView *mandelbrotView;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _mandelbrotView = [[MandelbrotView alloc] initWithParam:-2.0f cxmax:1.0f cymin:-2.0f cymax:2.0f rect:_scrollView.frame delegate:nil];
    [_scrollView addSubview:_mandelbrotView];
}

- (void)viewDidLayoutSubviews {
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _mandelbrotView;
}
@end
