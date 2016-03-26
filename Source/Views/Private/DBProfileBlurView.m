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
    UIImageView *_interpolatedImageView;
}

@property (nonatomic, strong) DBProfileBlurStageCache *cache;

@end

@implementation DBProfileBlurView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor clearColor];

        self.maxBlurRadius = 20.0;
        self.iterations = 3;
        self.numberOfStages = 15;
        self.shouldInterpolateStages = YES;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _interpolatedImageView = [[UIImageView alloc] init];
        _interpolatedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _interpolatedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _interpolatedImageView.clipsToBounds = YES;
        [self addSubview:_interpolatedImageView];
        
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
        
        self.cache = [[DBProfileBlurStageCache alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStage:(NSInteger)stage {
    _stage = stage;
    
    if (stage == 0) {
        _imageView.image = self.snapshot;
    } else {
        UIImage *blurredImage = [self blurredSnapshot:self.snapshot stage:stage];
        if (blurredImage) _imageView.image = blurredImage;
        
        if (self.shouldInterpolateStages) {
            UIImage *blurredImage = [self blurredSnapshot:self.snapshot stage:stage + 1];
            _interpolatedImageView.image = blurredImage;
            _interpolatedImageView.alpha = 0.1;
        }
    }
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
    NSLog(@"%@", @(stage * (self.maxBlurRadius / self.numberOfStages)));
    return stage * (self.maxBlurRadius / self.numberOfStages);
}

- (UIImage *)blurredSnapshot:(UIImage *)snapshot stage:(CGFloat)stage
{
    DBProfileBlurStageCacheKey *key = [[DBProfileBlurStageCacheKey alloc] initWithImage:snapshot
                                                                              tintColor:self.tintColor
                                                                                  stage:stage];
    return [self.cache objectForKey:key];
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
                [self.cache setObject:blurredImage forKey:key];
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
