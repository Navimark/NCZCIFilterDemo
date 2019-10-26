//
//  RMXAlphaFrameFilter.h
//  GPUVideoPlayer
//
//  Created by chenzheng on 2019/10/26.
//  Copyright © 2019 QB. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMXAlphaFrameFilter : CIFilter

@property (nonatomic) CIImage *inputImage;
@property (nonatomic) CIImage *maskImage;

@end

NS_ASSUME_NONNULL_END
