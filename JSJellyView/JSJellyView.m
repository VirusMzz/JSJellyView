//
//  JSJellyView.m
//  JSJellyView
//
//  Created by V on 11/4/2016.
//  Copyright © 2016 V. All rights reserved.
//

#import "JSJellyView.h"

#define ScreenWidh      ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight    ([UIScreen mainScreen].bounds.size.height)
#define MIN_HEIGHT      300

static NSString *kx = @"curX";
static NSString *ky = @"curY";

@interface JSJellyView ()

//利用curView的动画来计算坐标，从而实时刷新动画的path
@property (nonatomic, strong)UIView *curView;

//shapelayer,jelly部分的边缘
@property (nonatomic, strong)CAShapeLayer *shapeLayer;
//用于做动画的View的坐标
@property (nonatomic, assign)CGFloat curX;
@property (nonatomic, assign)CGFloat curY;
//用于当前是否处于动画状态
@property (nonatomic, assign)BOOL isAnimating;

//用于刷新
@property (nonatomic, strong)CADisplayLink *displaylink;

@end

@implementation JSJellyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addObserver:self forKeyPath:kx options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:ky options:NSKeyValueObservingOptionNew context:nil];
        [self configShapeLayer];
        [self configAction];
        [self configCurView];
        
        
        
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

    if([keyPath isEqualToString:kx] || [keyPath isEqualToString:ky]){
    
        [self updatePath];
    }
    
}

//观察到坐标变化就更新path
- (void)updatePath{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //各个点
    CGPoint p1 = CGPointMake(0, 0);
    CGPoint p2 = CGPointMake(ScreenWidh, 0);
    CGPoint p3 = CGPointMake(ScreenWidh, MIN_HEIGHT);
    CGPoint p4 = CGPointMake(self.curX, self.curY);
    CGPoint p5 = CGPointMake(0, MIN_HEIGHT);
    
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addQuadCurveToPoint:p5 controlPoint:p4];
    [path closePath];
    NSLog(@"%@",self.shapeLayer.path);
    self.shapeLayer.path = path.CGPath;
}


#pragma mark -- config
//设置curView
- (void)configCurView{

    self.curX = ScreenWidh / 2.0;
    self.curY = MIN_HEIGHT;
    
    self.curView = [[UIView alloc]initWithFrame:CGRectMake(_curX, _curY, 5, 5)];
    self.curView.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.curView];
}


//CAShapeLayer动画仅仅限于沿着边缘的动画效果,它实现不了填充效果
- (void)configShapeLayer{

    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor blueColor].CGColor;
    
    [self.layer addSublayer:self.shapeLayer];
    
}

//设置动作手势
- (void)configAction{

    _isAnimating = NO;
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTouched:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:panGes];
    
    
    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(caculatePath)];
    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.displaylink.paused = YES;
    
}

- (void)caculatePath{

    CALayer *curViewLayer = [self.curView.layer presentationLayer];
    self.curX = curViewLayer.frame.origin.x;
    self.curY = curViewLayer.frame.origin.y;
}


- (void)panTouched:(UIPanGestureRecognizer *)pan{

    //如果未开始动画，形变path，拉伸
    if(!_isAnimating){
    
        if(pan.state == UIGestureRecognizerStateChanged){
        
            //滑动时获取当前手势的位置
            CGPoint curPoint = [pan translationInView:self];
            self.curX = curPoint.x + ScreenWidh / 2;
            
            CGFloat height = curPoint.y + MIN_HEIGHT;
            self.curY = height > MIN_HEIGHT? height : MIN_HEIGHT;
            
            self.curView.frame = CGRectMake(self.curX, self.curY, 5, 5);
        }
        //开始动画
        else if(pan.state == UIGestureRecognizerStateEnded ||
                pan.state == UIGestureRecognizerStateFailed ||
                pan.state == UIGestureRecognizerStateCancelled){
            
            _isAnimating = YES;
            _displaylink.paused = NO;
            
            
            [UIView animateWithDuration:0.5
                                  delay:0.0
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.curView.frame = CGRectMake(ScreenWidh / 2.0, MIN_HEIGHT, 5, 5);
                             } completion:^(BOOL finished) {
                                 
                                 if (finished) {
                                     
                                     _isAnimating = NO;
                                     _displaylink.paused = YES;
                                     
                                 }
                             }];
            
            
        }
    }
    
    
}

//移除观察
- (void)dealloc{

    [self removeObserver:self forKeyPath:kx];
    [self removeObserver:self forKeyPath:ky];
}


@end

