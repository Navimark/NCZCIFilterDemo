//
//  ViewController.m
//  GPUVideoPlayer
//
//  Created by chenzheng on 2019/10/25.
//  Copyright © 2019 QB. All rights reserved.
//

#import "ViewController.h"
#import "RMXAlphaVideoPlayerView.h"
#import <ReactiveObjC.h>
#import <Masonry.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImgView;
@property (nonatomic, weak) RMXAlphaVideoPlayerView *playerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [[[RACSignal interval:2 onScheduler:[RACScheduler scheduler]] deliverOnMainThread] subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self);
        self.backgroundImgView.highlighted = !self.backgroundImgView.isHighlighted;
    }];
    RMXAlphaVideoPlayerView *view = [RMXAlphaVideoPlayerView playerWithVideoName:@"hhyt"];
    [self.view addSubview:self.playerView = view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.playerView play];
//    self.playerView.layer.borderColor = [UIColor redColor].CGColor;
//    self.playerView.layer.borderWidth = 1;
}

- (void)btnAction
{
    
}

- (void)btnAction2
{
//    SimpleVideoFilterViewController *vc = [[SimpleVideoFilterViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
