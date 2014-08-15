// Copyright (c) 2014, Daniel Andersen (daniel@trollsahead.dk)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Util.h"

@implementation Util

+ (UIInterfaceOrientation)interfaceOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

+ (bool)isLandscapeOrientation {
    return UIInterfaceOrientationIsLandscape([self interfaceOrientation]);
}

+ (bool)isPortraitOrientation {
    return UIInterfaceOrientationIsPortrait([self interfaceOrientation]);
}

+ (UIImage *)radialGradientWithSize:(CGSize)size centerPosition:(CGPoint)p radius:(float)radius {
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t colorsCount = 2;
    float locations[2] = {0.0f, 1.0f};
    float colors[8] = {
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 0.0f
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, colorsCount);
    
    CGContextDrawRadialGradient(context, gradient, p, 0.0f, p, radius, kCGGradientDrawsAfterEndLocation);
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    
    return outputImage;
}

+ (void)saveImage:(UIImage *)image toDocumentsFolderWithPrefix:(NSString *)prefix {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    
    NSString *filename = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"screenshot_%@_%@.png", prefix, [formatter stringFromDate:[NSDate date]]]];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filename atomically:NO];
}

+ (NSArray *)setViewToFillParent:(UIView *)view {
    return [self setViewToFillParent:view currentViewConstraints:nil];
}

+ (NSArray *)setViewToFillParent:(UIView *)view currentViewConstraints:(NSArray *)currentConstraints {
    if (view.superview != nil) {
        if (currentConstraints != nil) {
            [view.superview removeConstraints:currentConstraints];
        }
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
        [view.superview addConstraints:constraints];
        return constraints;
    } else {
        return nil;
    }
}

+ (void)removeSubViews:(UIView *)containerView {
    while (containerView.subviews.count > 0) {
        UIView *subview = [containerView.subviews lastObject];
        [subview removeFromSuperview];
    }
}

+ (int)randomIntFrom:(int)lowerValue to:(int)higherValue {
    return lowerValue + (rand() % (higherValue - lowerValue));
}

@end
