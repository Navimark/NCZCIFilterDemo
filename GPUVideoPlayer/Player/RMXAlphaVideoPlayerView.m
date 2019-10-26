//
//  RMXAlphaVideoPlayerView.m
//  GPUVideoPlayer
//
//  Created by chenzheng on 2019/10/26.
//  Copyright © 2019 QB. All rights reserved.
//

#import "RMXAlphaVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "RMXAlphaFrameFilter.h"
#import <ReactiveObjC.h>

@interface RMXAlphaVideoPlayerView ()

@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, readonly) AVPlayer *player;
@property (nonatomic, weak) AVPlayerItem *playerItem;
@property (nonatomic) RACDisposable *loopPlayDisposable;

@end

@implementation RMXAlphaVideoPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayer *)player
{
    return self.playerLayer.player;
}

- (void)dealloc
{
    [_loopPlayDisposable dispose];
}

+ (instancetype)playerWithVideoName:(NSString *)vName
{
    RMXAlphaVideoPlayerView *v = [[RMXAlphaVideoPlayerView alloc] initWithFrame:CGRectZero];
    v.videoName = vName;
    [v preparePlayer];
    [v prepareVideoWithCompletion:nil];
    return v;
}

- (void)play
{
    if (!self.playerItem) {
        NSLog(@"没有加载到");
        return;
    }
    [self setupPlayerItem];
    [self.loopPlayDisposable dispose];
    @weakify(self);
    self.loopPlayDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.player play];
}

- (void)preparePlayer
{
    self.playerLayer.pixelBufferAttributes = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA) };
    self.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.playerLayer.contentsGravity = kCAGravityResizeAspectFill;
}

- (void)prepareVideoWithCompletion:(void(^)(void))completionHandler
{
    NSURL *vURL = [[NSBundle mainBundle] URLForResource:self.videoName withExtension:@".mp4"];
    AVAsset *asset = [AVURLAsset assetWithURL:vURL];
    [asset loadValuesAsynchronouslyForKeys:@[@"duration",@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playerLayer.player = [[AVPlayer alloc] initWithPlayerItem:(self.playerItem = [AVPlayerItem playerItemWithAsset:asset])];
            !completionHandler ?: completionHandler();
        });
    }];
}

- (void)setupPlayerItem
{
    NSArray<AVAssetTrack *> *tracks = self.playerItem.asset.tracks;
    if (tracks == 0) {
        NSLog(@"视频不合法");
        return;
    }
    if (self.playerItem.videoComposition) {
        NSLog(@"已经添加 filter 了");
        return;
    }
    
    CGSize videoSize = CGSizeMake(tracks[0].naturalSize.width, tracks[0].naturalSize.height);
    NSLog(@"videoSize = %@",NSStringFromCGSize(videoSize));
    NSAssert(videoSize.width > 0 && videoSize.height > 0, @"轨道数据错误");
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:self.playerItem.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CGRect sourceRect = (CGRect){(CGPoint){0.5 * videoSize.width, 0},CGSizeMake(0.5 * videoSize.width, videoSize.height)};
        CGRect alphaRect = CGRectOffset(sourceRect, -0.5 * videoSize.width, 0);
        RMXAlphaFrameFilter *filter = [[RMXAlphaFrameFilter alloc] init];
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -0.5 * videoSize.width, 0);
        filter.inputImage = [[request.sourceImage imageByCroppingToRect:sourceRect] imageByApplyingTransform:transform];
        filter.maskImage = [request.sourceImage imageByCroppingToRect:alphaRect];
        
        return [request finishWithImage:filter.outputImage context:nil];
    }];
    videoComposition.renderSize = CGSizeMake(0.5 * videoSize.width, videoSize.height);
    self.playerItem.videoComposition = videoComposition;
    self.playerItem.seekingWaitsForVideoCompositionRendering = YES;
}

@end
/**
 naturalSize: {1440, 1280}
 sourceRect: 720,0, 720, 1280
 alphaRect: 0,0, 720, 1280
 
 translatrion: 0, -286
 inputImage 和 maskImage 的extent 都为 0, 0, 460, 286 (都是 sourceRect)
 
 */
