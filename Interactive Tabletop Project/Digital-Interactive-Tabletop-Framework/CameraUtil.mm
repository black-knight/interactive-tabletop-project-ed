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

#import "CameraUtil.h"
#import "ExternalDisplay.h"
#import "UIImage+OpenCV.h"

@implementation CameraUtil

+ (UIImage *)imageFromPixelBuffer:(CVImageBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CGImageRelease(cgImage);

    return uiImage;
}

+ (cv::Mat)perspectiveTransformImage:(cv::Mat)image withTransformation:(cv::Mat)transformation {
    return [self perspectiveTransformImage:image withTransformation:transformation toSize:[ExternalDisplay instance].widescreenBounds.size];
}

+ (cv::Mat)perspectiveTransformImage:(cv::Mat)src withTransformation:(cv::Mat)transformation toSize:(CGSize)toSize {
    cv::Mat dst;
    cv::Size size = cv::Size(toSize.width, toSize.height);
    cv::warpPerspective(src, dst, transformation, size);
    return dst;
}

+ (cv::Mat)findPerspectiveTransformationSrcPoints:(FourPoints)srcPoints dstPoints:(FourPoints)dstPoints {
    cv::Point2f srcCvPoints[4];
    srcCvPoints[0] = cv::Point2f(srcPoints.p1.x, srcPoints.p1.y);
    srcCvPoints[1] = cv::Point2f(srcPoints.p2.x, srcPoints.p2.y);
    srcCvPoints[2] = cv::Point2f(srcPoints.p3.x, srcPoints.p3.y);
    srcCvPoints[3] = cv::Point2f(srcPoints.p4.x, srcPoints.p4.y);

    cv::Point2f dstCvPoints[4];
    dstCvPoints[0] = cv::Point2f(dstPoints.p1.x, dstPoints.p1.y);
    dstCvPoints[1] = cv::Point2f(dstPoints.p2.x, dstPoints.p2.y);
    dstCvPoints[2] = cv::Point2f(dstPoints.p3.x, dstPoints.p3.y);
    dstCvPoints[3] = cv::Point2f(dstPoints.p4.x, dstPoints.p4.y);
    
    return cv::getPerspectiveTransform(srcCvPoints, dstCvPoints);
}

+ (UIInterfaceOrientation)interfaceOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

+ (UIImageOrientation)interfaceOrientationToImageOrientation {
    switch ([self interfaceOrientation]) {
        case UIInterfaceOrientationLandscapeLeft:
            return UIImageOrientationDown;
        case UIInterfaceOrientationLandscapeRight:
            return UIImageOrientationUp;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIImageOrientationLeft;
        default:
            return UIImageOrientationRight;
    }
}

@end
