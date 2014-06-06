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

#import "BoardUtil.h"
#import "ExternalDisplay.h"
#import "Constants.h"

BoardUtil *boardUtilInstance = nil;

@implementation BoardUtil

+ (BoardUtil *)instance {
    @synchronized(self) {
        if (boardUtilInstance == nil) {
            boardUtilInstance = [[BoardUtil alloc] init];
        }
        return boardUtilInstance;
    }
}

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
}

- (CGSize)singleBrickScreenSize {
    return [Constants instance].brickSize;
}

- (CGSize)singleBrickScreenSizeFromBoardSize:(CGSize)size {
    return CGSizeMake(size.width / [Constants instance].gridSize.width, size.height / [Constants instance].gridSize.height);
}

- (CGPoint)brickScreenPosition:(cv::Point)brickBoardPosition {
    return CGPointMake((int)(brickBoardPosition.x * [self singleBrickScreenSize].width) + 1.0f, (int)(brickBoardPosition.y * [self singleBrickScreenSize].height) + 1.0f);
}

- (CGRect)brickScreenRect:(cv::Point)brickBoardPosition {
    CGPoint p = [self brickScreenPosition:brickBoardPosition];
    CGSize size = [self singleBrickScreenSize];
    return CGRectMake(p.x, p.y, size.width, size.height);
}

- (CGRect)bricksScreenRectPosition1:(cv::Point)p1 position2:(cv::Point)p2 {
    CGRect r1 = [self brickScreenRect:p1];
    CGRect r2 = [self brickScreenRect:p2];
    CGPoint p = CGPointMake(MIN(r1.origin.x, r2.origin.x), MIN(r1.origin.y, r2.origin.y));
    CGSize size = CGSizeMake(MAX(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width) - p.x, MAX(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height) - p.y);
    return CGRectMake(p.x, p.y, size.width, size.height);
}

- (CGPoint)cvPointToCGPoint:(cv::Point)p {
    return CGPointMake(p.x, p.y);
}

@end