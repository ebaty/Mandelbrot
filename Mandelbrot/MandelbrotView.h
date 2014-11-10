//
//  MandelbrotView.h
//  Mandelbrot
//
//  Created by Masaki EBATA on 2014/11/10.
//  Copyright (c) 2014年 GMO Payment Gateway, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MandelbrotView;

@protocol MandelbrotViewDelegate <NSObject>

@optional
- (void)didEndDrawRect:(MandelbrotView *)view;

@end

@interface MandelbrotView : UIView

@property (nonatomic) id<MandelbrotViewDelegate> delegate;

- (id)initWithParam:(double)cxmin cxmax:(double)cxmax cymin:(double)cymin cymax:(double)cymax rect:(CGRect)rect delegate:(id<MandelbrotViewDelegate>)delegate;
@end
