//
//  RMXAlphaVideoPlayerView.h
//  GPUVideoPlayer
//
//  Created by chenzheng on 2019/10/26.
//  Copyright © 2019 QB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMXAlphaVideoPlayerView : UIView

+ (instancetype)playerWithVideoName:(NSString *)vName;

- (void)play;

@end

NS_ASSUME_NONNULL_END
