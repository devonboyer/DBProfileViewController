//
//  DBProfileBlurView.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-25.
//
//

#import "DBProfileBlurView.h"
#import <FXBlurView/FXBlurView.h>

@interface DBProfileBlurStageCacheKey : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) NSUInteger stage;

@end

@implementation DBProfileBlurStageCacheKey

- (instancetype)initWithImage:(UIImage *)image tintColor:(UIColor *)tintColor stage:(NSUInteger)stage {
    self = [super init];
    if (self) {
        _image = image;
        _tintColor = tintColor;
        _stage = stage;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    __typeof(self) castObject = object;
    return ([_image isEqual:castObject.image]
            && [_tintColor isEqual:castObject.tintColor]
            && _stage == castObject.stage);
}

@end

@interface DBProfileBlurStageCache : NSCache
@end

@implementation DBProfileBlurStageCache

+ (instancetype)sharedCache {
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

@end

@interface DBProfileBlurView () {
    UIImageView *_imageView;
}

@property (nonatomic, strong) NSLock *lock;

@end

@implementation DBProfileBlurView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor clearColor];

        self.maxBlurRadius = 60.0;
        self.iterations = 3;
        self.numberOfStages = 20;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          [self updateAsynchronously:NO completion:nil];
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          [self updateAsynchronously:NO completion:nil];
                                                      }];
        
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStage:(NSInteger)stage {
    _stage = stage;
    
    [self.lock lock];
    if (stage == 0) {
        _imageView.image = self.snapshot;
    } else {
        UIImage *blurredImage = [self blurredSnapshot:self.snapshot stage:stage];
        if (blurredImage) _imageView.image = blurredImage;
    }
    [self.lock unlock];
}

- (void)setSnapshot:(UIImage *)snapshot {
    _snapshot = snapshot;
    _imageView.image = snapshot;
    [self updateAsynchronously:YES completion:nil];
}

- (BOOL)shouldUpdate
{
    return YES;
}

- (CGFloat)blurRadiusForStage:(NSInteger)stage
{
    return stage * (self.maxBlurRadius / self.numberOfStages);
}

- (UIImage *)blurredSnapshot:(UIImage *)snapshot stage:(CGFloat)stage
{
    DBProfileBlurStageCacheKey *key = [[DBProfileBlurStageCacheKey alloc] initWithImage:snapshot
                                                                              tintColor:self.tintColor
                                                                                  stage:stage];
    return [[DBProfileBlurStageCache sharedCache] objectForKey:key];
}

- (void)updateAsynchronously:(BOOL)async completion:(void (^)())completion
{
    if ([self shouldUpdate]) {
        UIImage *snapshot = self.snapshot;
        
        void (^block)() = ^void(){
            for (NSInteger stage = 0; stage <= self.numberOfStages; stage++) {
                DBProfileBlurStageCacheKey *key = [[DBProfileBlurStageCacheKey alloc] initWithImage:snapshot
                                                                                          tintColor:self.tintColor
                                                                                              stage:stage];
                UIImage *blurredImage = [snapshot blurredImageWithRadius:[self blurRadiusForStage:stage]
                                                              iterations:self.iterations
                                                               tintColor:self.tintColor];
                [[DBProfileBlurStageCache sharedCache] setObject:blurredImage forKey:key];
            }
        };
        
        if (async) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block();
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (completion) completion();
                });
            });
        }
        else {
            block();
            if (completion) completion();
        }
    }
    else if (completion) {
        completion();
    }
}

@end
