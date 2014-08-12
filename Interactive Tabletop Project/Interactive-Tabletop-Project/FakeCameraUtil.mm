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

#import "FakeCameraUtil.h"
#import "UIImage+OpenCV.h"
#import "CameraUtil.h"
#import "BoardUtil.h"
#import "Constants.h"

@interface FakeCameraUtil ()

@property (nonatomic, strong) UIImage *fakeCameraImage;
@property (nonatomic, strong) NSMutableArray *brickChecked;

@end

@implementation FakeCameraUtil

FakeCameraUtil *fakeCameraUtilInstance = nil;

+ (FakeCameraUtil *)instance {
    @synchronized(self) {
        if (fakeCameraUtilInstance == nil) {
            fakeCameraUtilInstance = [[FakeCameraUtil alloc] init];
        }
        return fakeCameraUtilInstance;
    }
}

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.brickChecked = [NSMutableArray array];
    for (int i = 0; i < [Constants instance].gridSize.height; i++) {
        NSMutableArray *rowArray = [NSMutableArray array];
        for (int j = 0; j < [Constants instance].gridSize.width; j++) {
            [rowArray addObject:[NSNumber numberWithBool:NO]];
        }
        [self.brickChecked addObject:rowArray];
    }
}

- (UIImage *)fakePerspectiveOnImage:(UIImage *)image {
    FourPoints srcPoints = {
        .p1 = CGPointMake(0.0f, 0.0f),
        .p2 = CGPointMake(image.size.width, 0.0f),
        .p3 = CGPointMake(image.size.width, image.size.height),
        .p4 = CGPointMake(0.0f, image.size.height)
    };
    FourPoints dstPoints = {
        .p1 = CGPointMake(1.0f, 1.0f),
        .p2 = CGPointMake(image.size.width - 1.0f, 1.0f),
        .p3 = CGPointMake(image.size.width - 1.0f, image.size.height - 1.0f),
        .p4 = CGPointMake(1.0f, image.size.height - 1.0f)
    };
    cv::Mat transformation = [CameraUtil findPerspectiveTransformationSrcPoints:srcPoints dstPoints:dstPoints];
    cv::Mat outputImg = [CameraUtil perspectiveTransformImage:[image CVMat] withTransformation:transformation toSize:image.size];
    return [UIImage imageWithCVMat:outputImg];
}

- (UIImage *)rotateImageToLandscapeMode:(UIImage *)image {
    return [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
}

- (UIImage *)fakeOutputImage {
    if (self.fakeCameraImage == nil) {
        self.fakeCameraImage = [UIImage imageNamed:@"fake_board_6.png"];
    }
    return self.fakeCameraImage;
}

- (UIImage *)drawBricksWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawBricksInContext:context withSize:size];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *)drawBricksOnImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
    [self drawBricksInContext:context withSize:image.size];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (void)drawBricksInContext:(CGContextRef)context withSize:(CGSize)size {
    for (int i = 0; i < [Constants instance].gridSize.height; i++) {
        NSArray *rowArray = [self.brickChecked objectAtIndex:i];
        for (int j = 0; j < [Constants instance].gridSize.width; j++) {
            NSNumber *checked = [rowArray objectAtIndex:j];
            if (checked.boolValue) {
                CGRect rect = [[BoardUtil instance] brickScreenRect:cv::Point(j, i)];
                rect.origin.x += 2.0f;
                rect.origin.y += 2.0f;
                rect.size.width -= 4.0f;
                rect.size.height -= 4.0f;
                CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextFillRect(context, rect);
            }
        }
    }
}

- (void)clickAtPoint:(cv::Point)p {
    NSMutableArray *rowArray = [self.brickChecked objectAtIndex:(int)p.y];
    NSNumber *checked = [rowArray objectAtIndex:(int)p.x];
    [rowArray setObject:[NSNumber numberWithBool:!checked.boolValue] atIndexedSubscript:(int)p.x];
}

@end
