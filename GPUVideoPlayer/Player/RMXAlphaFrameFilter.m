//
//  RMXAlphaFrameFilter.m
//  GPUVideoPlayer
//
//  Created by chenzheng on 2019/10/26.
//  Copyright © 2019 QB. All rights reserved.
//

#import "RMXAlphaFrameFilter.h"

static CIColorKernel *kernel(void)
{
    static CIColorKernel *s_kernel = nil;
    if (!s_kernel) {
        NSString *kernelStr = @"kernel vec4 alphaFrame(__sample s, __sample m) {return vec4(s.rgb, m.r);}";
        s_kernel = [CIColorKernel kernelWithString:kernelStr];
    }
    return s_kernel;
}

@interface RMXAlphaFrameFilter ()

@end

@implementation RMXAlphaFrameFilter

- (CIImage *)outputImage
{
    if (!self.inputImage || !self.maskImage) {
        return nil;
    }
    return [kernel() applyWithExtent:self.inputImage.extent arguments:@[self.inputImage, self.maskImage]];
}

@end
