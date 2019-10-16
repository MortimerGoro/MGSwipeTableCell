/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2016 Imanol Fernandez @MortimerGoro
 */

#import "MGSwipeTableCell.h"

#pragma mark Input Overlay Helper Class
/** Used to capture table input while swipe buttons are visible*/
@interface MGSwipeTableInputOverlay : UIView
@property (nonatomic, weak) MGSwipeTableCell * currentCell;
@end

@implementation MGSwipeTableInputOverlay

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (event == nil) {
        return nil;
    }
    if (!_currentCell) {
        [self removeFromSuperview];
        return nil;
    }
    CGPoint p = [self convertPoint:point toView:_currentCell];
    if (_currentCell && (_currentCell.hidden || CGRectContainsPoint(_currentCell.bounds, p))) {
        return nil;
    }
    BOOL hide = YES;
    if (_currentCell && _currentCell.delegate && [_currentCell.delegate respondsToSelector:@selector(swipeTableCell:shouldHideSwipeOnTap:)]) {
        hide = [_currentCell.delegate swipeTableCell:_currentCell shouldHideSwipeOnTap:p];
    }
    if (hide) {
        [_currentCell hideSwipeAnimated:YES];
    }
    return _currentCell.touchOnDismissSwipe ? nil : self;
}

@end

#pragma mark Button Container View and transitions

@interface MGSwipeButtonsView : UIView
@property (nonatomic, weak) MGSwipeTableCell * cell;
@property (nonatomic, strong) UIColor * backgroundColorCopy;
@end

@implementation MGSwipeButtonsView
{
    NSArray * _buttons;
    UIView * _container;
    BOOL _fromLeft;
    UIView * _expandedButton;
    UIView * _expandedButtonAnimated;
    UIView * _expansionBackground;
    UIView * _expansionBackgroundAnimated;
    CGRect _expandedButtonBoundsCopy;
    MGSwipeDirection _direction;
    MGSwipeExpansionLayout _expansionLayout;
    CGFloat _expansionOffset;
    CGFloat _buttonsDistance;
    CGFloat _safeInset;
    BOOL _autoHideExpansion;
}

#pragma mark Layout

-(instancetype) initWithButtons:(NSArray*) buttonsArray direction:(MGSwipeDirection) direction swipeSettings:(MGSwipeSettings*) settings safeInset: (CGFloat) safeInset
{
    CGFloat containerWidth = 0;
    CGSize maxSize = CGSizeZero;
    UIView* lastButton = [buttonsArray lastObject];
    for (UIView * button in buttonsArray) {
        containerWidth += button.bounds.size.width + (lastButton == button ? 0 : settings.buttonsDistance);
        maxSize.width = MAX(maxSize.width, button.bounds.size.width);
        maxSize.height = MAX(maxSize.height, button.bounds.size.height);
    }
    if (!settings.allowsButtonsWithDifferentWidth) {
        containerWidth = maxSize.width * buttonsArray.count + settings.buttonsDistance * (buttonsArray.count - 1);
    }
    
    if (self = [super initWithFrame:CGRectMake(0, 0, containerWidth + safeInset, maxSize.height)]) {
        _fromLeft = direction == MGSwipeDirectionLeftToRight;
        _buttonsDistance = settings.buttonsDistance;
        _container = [[UIView alloc] initWithFrame:self.bounds];
        _container.clipsToBounds = YES;
        _container.backgroundColor = [UIColor clearColor];
        _direction = direction;
        _safeInset = safeInset;
        [self addSubview:_container];
        _buttons = _fromLeft ? buttonsArray: [[buttonsArray reverseObjectEnumerator] allObjects];
        for (UIView * button in _buttons) {
            if ([button isKindOfClass:[UIButton class]]) {
                UIButton * btn = (UIButton*)button;
                [btn removeTarget:nil action:@selector(mgButtonClicked:) forControlEvents:UIControlEventTouchUpInside]; //Remove all targets to avoid problems with reused buttons among many cells
                [btn addTarget:self action:@selector(mgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            if (!settings.allowsButtonsWithDifferentWidth) {
                button.frame = CGRectMake(0, 0, maxSize.width, maxSize.height);
            }
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [_container insertSubview:button atIndex: _fromLeft ? 0: _container.subviews.count];
        }
        // Expand last button to make it look good with a notch.
        if (safeInset > 0 && settings.expandLastButtonBySafeAreaInsets && _buttons.count > 0) {
            UIView * notchButton = _direction == MGSwipeDirectionRightToLeft ? [_buttons lastObject] : [_buttons firstObject];
            notchButton.frame = CGRectMake(0, 0, notchButton.frame.size.width + safeInset, notchButton.frame.size.height);
            [self adjustContentEdge:notchButton edgeDelta:safeInset];
        }
        [self resetButtons];
    }
    return self;
}

-(void) dealloc
{
    for (UIView * button in _buttons) {
        if ([button isKindOfClass:[UIButton class]]) {
            [(UIButton *)button removeTarget:self action:@selector(mgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

-(void) resetButtons
{
    CGFloat offsetX = 0;
    UIView* lastButton = [_buttons lastObject];
    for (UIView * button in _buttons) {
        button.frame = CGRectMake(offsetX, 0, button.bounds.size.width, self.bounds.size.height);
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        offsetX += button.bounds.size.width + (lastButton == button ? 0 : _buttonsDistance);
    }
}

-(void) setSafeInset:(CGFloat)safeInset extendEdgeButton:(BOOL) extendEdgeButton isRTL: (BOOL) isRTL {
    CGFloat diff = safeInset - _safeInset;
    if (diff != 0) {
        _safeInset = safeInset;
        // Adjust last button length (fit the safeInset to make it look good with a notch)
        if (extendEdgeButton) {
            UIView * edgeButton = _direction == MGSwipeDirectionRightToLeft ? [_buttons lastObject] : [_buttons firstObject];
            edgeButton.frame = CGRectMake(0, 0, edgeButton.bounds.size.width + diff, edgeButton.frame.size.height);
            // Adjust last button content edge (to correctly align the text/icon)
            [self adjustContentEdge:edgeButton edgeDelta:diff];
        }

        CGRect frame = self.frame;
        CGAffineTransform transform = self.transform;
        self.transform = CGAffineTransformIdentity;
        // Adjust container width
        frame.size.width += diff;
        // Adjust position to match width and safeInsets chages
        if (_direction == MGSwipeDirectionLeftToRight) {
            frame.origin.x = -frame.size.width + safeInset * (isRTL ? 1 : -1);
        }
        else {
            frame.origin.x = self.superview.bounds.size.width + safeInset * (isRTL ? 1 : -1);
        }
        
        self.frame = frame;
        self.transform = transform;
        [self resetButtons];
    }
}

-(void) adjustContentEdge: (UIView *) view edgeDelta:(CGFloat) delta {
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton * btn = (UIButton *) view;
        UIEdgeInsets contentInsets = btn.contentEdgeInsets;
        if (_direction == MGSwipeDirectionRightToLeft) {
            contentInsets.right += delta;
        }
        else {
            contentInsets.left += delta;
        }
        btn.contentEdgeInsets = contentInsets;
    }
}

-(void) layoutExpansion: (CGFloat) offset
{
    _expansionOffset = offset;
    _container.frame = CGRectMake(_fromLeft ? 0: self.bounds.size.width - offset, 0, offset, self.bounds.size.height);
    if (_expansionBackgroundAnimated && _expandedButtonAnimated) {
        _expansionBackgroundAnimated.frame = [self expansionBackgroundRect:_expandedButtonAnimated];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if (_expandedButton) {
        [self layoutExpansion:_expansionOffset];
    }
    else {
        _container.frame = self.bounds;
    }
}

-(CGRect) expansionBackgroundRect: (UIView *) button
{
    CGFloat extra = 100.0f; //extra size to avoid expansion background size issue on iOS 7.0
    if (_fromLeft) {
        return CGRectMake(-extra, 0, button.frame.origin.x + extra, _container.bounds.size.height);
    }
    else {
        return CGRectMake(button.frame.origin.x +  button.bounds.size.width, 0,
                   _container.bounds.size.width - (button.frame.origin.x + button.bounds.size.width ) + extra
                          ,_container.bounds.size.height);
    }
    
}

-(void) expandToOffset:(CGFloat) offset settings:(MGSwipeExpansionSettings*) settings
{
    if (settings.buttonIndex < 0 || settings.buttonIndex >= _buttons.count) {
        return;
    }
    if (!_expandedButton) {
        _expandedButton = [_buttons objectAtIndex: _fromLeft ? settings.buttonIndex : _buttons.count - settings.buttonIndex - 1];
        CGRect previusRect = _container.frame;
        [self layoutExpansion:offset];
        [self resetButtons];
        if (!_fromLeft) { //Fix expansion animation for right buttons
            for (UIView * button in _buttons) {
                CGRect frame = button.frame;
                frame.origin.x += _container.bounds.size.width - previusRect.size.width;
                button.frame = frame;
            }
        }
        _expansionBackground = [[UIView alloc] initWithFrame:[self expansionBackgroundRect:_expandedButton]];
        _expansionBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (settings.expansionColor) {
            _backgroundColorCopy = _expandedButton.backgroundColor;
            _expandedButton.backgroundColor = settings.expansionColor;
        }
        _expansionBackground.backgroundColor = _expandedButton.backgroundColor;
        if (UIColor.clearColor == _expandedButton.backgroundColor) {
          // Provides access to more complex content for display on the background
          _expansionBackground.layer.contents = _expandedButton.layer.contents;
        }
        [_container addSubview:_expansionBackground];
        _expansionLayout = settings.expansionLayout;
        
        CGFloat duration = _fromLeft ? _cell.leftExpansion.animationDuration : _cell.rightExpansion.animationDuration;
        [UIView animateWithDuration: duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self->_expandedButton.hidden = NO;

            if (self->_expansionLayout == MGSwipeExpansionLayoutCenter) {
                self->_expandedButtonBoundsCopy = self->_expandedButton.bounds;
                self->_expandedButton.layer.mask = nil;
                self->_expandedButton.layer.transform = CATransform3DIdentity;
                self->_expandedButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                [self->_expandedButton.superview bringSubviewToFront:self->_expandedButton];
                self->_expandedButton.frame = self->_container.bounds;
                self->_expansionBackground.frame = [self expansionBackgroundRect:self->_expandedButton];
            }
            else if (self->_expansionLayout == MGSwipeExpansionLayoutNone) {
                [self->_expandedButton.superview bringSubviewToFront:self->_expandedButton];
                self->_expansionBackground.frame = self->_container.bounds;
            }
            else if (self->_fromLeft) {
                self->_expandedButton.frame = CGRectMake(self->_container.bounds.size.width - self->_expandedButton.bounds.size.width, 0, self->_expandedButton.bounds.size.width, self->_expandedButton.bounds.size.height);
                self->_expandedButton.autoresizingMask|= UIViewAutoresizingFlexibleLeftMargin;
                self->_expansionBackground.frame = [self expansionBackgroundRect:self->_expandedButton];
            }
            else {
                self->_expandedButton.frame = CGRectMake(0, 0, self->_expandedButton.bounds.size.width, self->_expandedButton.bounds.size.height);
                self->_expandedButton.autoresizingMask|= UIViewAutoresizingFlexibleRightMargin;
                self->_expansionBackground.frame = [self expansionBackgroundRect:self->_expandedButton];
            }

        } completion:^(BOOL finished) {
        }];
        return;
    }
    [self layoutExpansion:offset];
}

-(void) endExpansionAnimated:(BOOL) animated
{
    if (_expandedButton) {
        _expandedButtonAnimated = _expandedButton;
        if (_expansionBackgroundAnimated && _expansionBackgroundAnimated != _expansionBackground) {
            [_expansionBackgroundAnimated removeFromSuperview];
        }
        _expansionBackgroundAnimated = _expansionBackground;
        _expansionBackground = nil;
        _expandedButton = nil;
        if (_backgroundColorCopy) {
            _expansionBackgroundAnimated.backgroundColor = _backgroundColorCopy;
            _expandedButtonAnimated.backgroundColor = _backgroundColorCopy;
            _backgroundColorCopy = nil;
        }
        CGFloat duration = _fromLeft ? _cell.leftExpansion.animationDuration : _cell.rightExpansion.animationDuration;
        [UIView animateWithDuration: animated ? duration : 0.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self->_container.frame = self.bounds;
            if (self->_expansionLayout == MGSwipeExpansionLayoutCenter) {
                self->_expandedButtonAnimated.frame = self->_expandedButtonBoundsCopy;
            }
            [self resetButtons];
            self->_expansionBackgroundAnimated.frame = [self expansionBackgroundRect:self->_expandedButtonAnimated];
        } completion:^(BOOL finished) {
            [self->_expansionBackgroundAnimated removeFromSuperview];
        }];
    }
    else if (_expansionBackground) {
        [_expansionBackground removeFromSuperview];
        _expansionBackground = nil;
    }
}

-(UIView*) getExpandedButton
{
    return _expandedButton;
}

#pragma mark Trigger Actions

-(BOOL) handleClick: (id) sender fromExpansion:(BOOL) fromExpansion
{
    bool autoHide = false;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([sender respondsToSelector:@selector(callMGSwipeConvenienceCallback:)]) {
        //call convenience block callback if exits (usage of MGSwipeButton class is not compulsory)
        autoHide = [sender performSelector:@selector(callMGSwipeConvenienceCallback:) withObject:_cell];
    }
#pragma clang diagnostic pop
    
    if (_cell.delegate && [_cell.delegate respondsToSelector:@selector(swipeTableCell:tappedButtonAtIndex:direction:fromExpansion:)]) {
        NSInteger index = [_buttons indexOfObject:sender];
        if (!_fromLeft) {
            index = _buttons.count - index - 1; //right buttons are reversed
        }
        autoHide|= [_cell.delegate swipeTableCell:_cell tappedButtonAtIndex:index direction:_fromLeft ? MGSwipeDirectionLeftToRight : MGSwipeDirectionRightToLeft fromExpansion:fromExpansion];
    }
    
    if (fromExpansion && autoHide) {
        _expandedButton = nil;
        _cell.swipeOffset = 0;
    }
    else if (autoHide) {
        [_cell hideSwipeAnimated:YES];
    }
    
    return autoHide;

}
//button listener
-(void) mgButtonClicked: (id) sender
{
    [self handleClick:sender fromExpansion:NO];
}


#pragma mark Transitions

-(void) transitionStatic:(CGFloat) t
{
    const CGFloat dx = self.bounds.size.width * (1.0 - t);
    CGFloat offsetX = 0;
    
    UIView* lastButton = [_buttons lastObject];
    for (UIView *button in _buttons) {
        CGRect frame = button.frame;
        frame.origin.x = offsetX + (_fromLeft ? dx : -dx);
        button.frame = frame;
        offsetX += frame.size.width + (button == lastButton ? 0 : _buttonsDistance);
    }
}

-(void) transitionDrag:(CGFloat) t
{
    //No Op, nothing to do ;)
}

-(void) transitionClip:(CGFloat) t
{
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat offsetX = 0;
    
    UIView* lastButton = [_buttons lastObject];
    for (UIView *button in _buttons) {
        CGRect frame = button.frame;
        CGFloat dx = roundf(frame.size.width * 0.5 * (1.0 - t)) ;
        frame.origin.x = _fromLeft ? (selfWidth - frame.size.width - offsetX) * (1.0 - t) + offsetX + dx : offsetX * t - dx;
        button.frame = frame;

        if (_buttons.count > 1) {
            CAShapeLayer *maskLayer = [CAShapeLayer new];
            CGRect maskRect = CGRectMake(dx - 0.5, 0, frame.size.width - 2 * dx + 1.5, frame.size.height);
            CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
            maskLayer.path = path;
            CGPathRelease(path);
            button.layer.mask = maskLayer;
        }

        offsetX += frame.size.width + (button == lastButton ? 0 : _buttonsDistance);
    }
}

-(void) transtitionFloatBorder:(CGFloat) t
{
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat offsetX = 0;
    
    UIView* lastButton = [_buttons lastObject];
    for (UIView *button in _buttons) {
        CGRect frame = button.frame;
        frame.origin.x = _fromLeft ? (selfWidth - frame.size.width - offsetX) * (1.0 - t) + offsetX : offsetX * t;
        button.frame = frame;
        offsetX += frame.size.width + (button == lastButton ? 0 : _buttonsDistance);
    }
}

-(void) transition3D:(CGFloat) t
{
    const CGFloat invert = _fromLeft ? 1.0 : -1.0;
    const CGFloat angle = M_PI_2 * (1.0 - t) * invert;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/400.0f; //perspective 1/z
    const CGFloat dx = -_container.bounds.size.width * 0.5 * invert;
    const CGFloat offset = dx * 2 * (1.0 - t);
    transform = CATransform3DTranslate(transform, dx - offset, 0, 0);
    transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0);
    transform = CATransform3DTranslate(transform, -dx, 0, 0);
    _container.layer.transform = transform;
}

-(void) transition:(MGSwipeTransition) mode percent:(CGFloat) t
{
    switch (mode) {
        case MGSwipeTransitionStatic: [self transitionStatic:t]; break;
        case MGSwipeTransitionDrag: [self transitionDrag:t]; break;
        case MGSwipeTransitionClipCenter: [self transitionClip:t]; break;
        case MGSwipeTransitionBorder: [self transtitionFloatBorder:t]; break;
        case MGSwipeTransitionRotate3D: [self transition3D:t]; break;
    }
    if (_expandedButtonAnimated && _expansionBackgroundAnimated) {
        _expansionBackgroundAnimated.frame = [self expansionBackgroundRect:_expandedButtonAnimated];
    }
}

@end

#pragma mark Settings Classes
@implementation MGSwipeSettings
-(instancetype) init
{
    if (self = [super init]) {
        self.transition = MGSwipeTransitionBorder;
        self.threshold = 0.5;
        self.offset = 0;
        self.expandLastButtonBySafeAreaInsets = YES;
        self.keepButtonsSwiped = YES;
        self.enableSwipeBounces = YES;
        self.swipeBounceRate = 1.0;
        self.showAnimation = [[MGSwipeAnimation alloc] init];
        self.hideAnimation = [[MGSwipeAnimation alloc] init];
        self.stretchAnimation = [[MGSwipeAnimation alloc] init];
    }
    return self;
}

-(void) setAnimationDuration:(CGFloat)duration
{
    _showAnimation.duration = duration;
    _hideAnimation.duration = duration;
    _stretchAnimation.duration = duration;
}

-(CGFloat) animationDuration {
    return _showAnimation.duration;
}

@end

@implementation MGSwipeExpansionSettings
-(instancetype) init
{
    if (self = [super init]) {
        self.buttonIndex = -1;
        self.threshold = 1.3;
        self.animationDuration = 0.2;
        self.triggerAnimation = [[MGSwipeAnimation alloc] init];
    }
    return self;
}
@end

@interface MGSwipeAnimationData : NSObject
@property (nonatomic, assign) CGFloat from;
@property (nonatomic, assign) CGFloat to;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CFTimeInterval start;
@property (nonatomic, strong) MGSwipeAnimation * animation;

@end

@implementation MGSwipeAnimationData
@end


#pragma mark Easing Functions and MGSwipeAnimation

static inline CGFloat mgEaseLinear(CGFloat t, CGFloat b, CGFloat c) {
    return c*t + b;
}

static inline CGFloat mgEaseInQuad(CGFloat t, CGFloat b, CGFloat c) {
    return c*t*t + b;
}
static inline CGFloat mgEaseOutQuad(CGFloat t, CGFloat b, CGFloat c) {
    return -c*t*(t-2) + b;
}
static inline CGFloat mgEaseInOutQuad(CGFloat t, CGFloat b, CGFloat c) {
    if ((t*=2) < 1) return c/2*t*t + b;
    --t;
    return -c/2 * (t*(t-2) - 1) + b;
}
static inline CGFloat mgEaseInCubic(CGFloat t, CGFloat b, CGFloat c) {
    return c*t*t*t + b;
}
static inline CGFloat mgEaseOutCubic(CGFloat t, CGFloat b, CGFloat c) {
    --t;
    return c*(t*t*t + 1) + b;
}
static inline CGFloat mgEaseInOutCubic(CGFloat t, CGFloat b, CGFloat c) {
    if ((t*=2) < 1) return c/2*t*t*t + b;
    t-=2;
    return c/2*(t*t*t + 2) + b;
}
static inline CGFloat mgEaseOutBounce(CGFloat t, CGFloat b, CGFloat c) {
    if (t < (1/2.75)) {
        return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
        t-=(1.5/2.75);
        return c*(7.5625*t*t + .75) + b;
    } else if (t < (2.5/2.75)) {
        t-=(2.25/2.75);
        return c*(7.5625*t*t + .9375) + b;
    } else {
        t-=(2.625/2.75);
        return c*(7.5625*t*t + .984375) + b;
    }
};
static inline CGFloat mgEaseInBounce(CGFloat t, CGFloat b, CGFloat c) {
    return c - mgEaseOutBounce (1.0 -t, 0, c) + b;
};

static inline CGFloat mgEaseInOutBounce(CGFloat t, CGFloat b, CGFloat c) {
    if (t < 0.5) return mgEaseInBounce (t*2, 0, c) * .5 + b;
    return mgEaseOutBounce (1.0 - t*2, 0, c) * .5 + c*.5 + b;
};

@implementation MGSwipeAnimation

-(instancetype) init {
    if (self = [super init]) {
        _duration = 0.3;
        _easingFunction = MGSwipeEasingFunctionCubicOut;
    }
    return self;
}

-(CGFloat) value:(CGFloat)elapsed duration:(CGFloat)duration from:(CGFloat)from to:(CGFloat)to
{
    CGFloat t = MIN(elapsed/duration, 1.0f);
    if (t == 1.0) {
        return to; //precise last value
    }
    CGFloat (*easingFunction)(CGFloat t, CGFloat b, CGFloat c) = 0;
    switch (_easingFunction) {
        case MGSwipeEasingFunctionLinear: easingFunction = mgEaseLinear;break;
        case MGSwipeEasingFunctionQuadIn: easingFunction = mgEaseInQuad;break;
        case MGSwipeEasingFunctionQuadOut: easingFunction = mgEaseOutQuad;break;
        case MGSwipeEasingFunctionQuadInOut: easingFunction = mgEaseInOutQuad;break;
        case MGSwipeEasingFunctionCubicIn: easingFunction = mgEaseInCubic;break;
        default:
        case MGSwipeEasingFunctionCubicOut: easingFunction = mgEaseOutCubic;break;
        case MGSwipeEasingFunctionCubicInOut: easingFunction = mgEaseInOutCubic;break;
        case MGSwipeEasingFunctionBounceIn: easingFunction = mgEaseInBounce;break;
        case MGSwipeEasingFunctionBounceOut: easingFunction = mgEaseOutBounce;break;
        case MGSwipeEasingFunctionBounceInOut: easingFunction = mgEaseInOutBounce;break;
    }
    return (*easingFunction)(t, from, to - from);
}

@end

#pragma mark MGSwipeTableCell Implementation


@implementation MGSwipeTableCell
{
    UITapGestureRecognizer * _tapRecognizer;
    UIPanGestureRecognizer * _panRecognizer;
    CGPoint _panStartPoint;
    CGFloat _panStartOffset;
    CGFloat _targetOffset;
    
    UIView * _swipeOverlay;
    UIImageView * _swipeView;
    UIView * _swipeContentView;
    MGSwipeButtonsView * _leftView;
    MGSwipeButtonsView * _rightView;
    bool _allowSwipeRightToLeft;
    bool _allowSwipeLeftToRight;
    __weak MGSwipeButtonsView * _activeExpansion;

    MGSwipeTableInputOverlay * _tableInputOverlay;
    bool _overlayEnabled;
    UITableViewCellSelectionStyle _previusSelectionStyle;
    NSMutableSet * _previusHiddenViews;
    UITableViewCellAccessoryType _previusAccessoryType;
    BOOL _triggerStateChanges;
    
    MGSwipeAnimationData * _animationData;
    void (^_animationCompletion)(BOOL finished);
    CADisplayLink * _displayLink;
    MGSwipeState _firstSwipeState;
}

#pragma mark View creation & layout

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self initViews:YES];
    }
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    if (!_panRecognizer) {
        [self initViews:YES];
    }
}

-(void) dealloc
{
    [self hideSwipeOverlayIfNeededIncludingReselect:false];
}

-(void) initViews: (BOOL) cleanButtons
{
    if (cleanButtons) {
        _leftButtons = [NSArray array];
        _rightButtons = [NSArray array];
        _leftSwipeSettings = [[MGSwipeSettings alloc] init];
        _rightSwipeSettings = [[MGSwipeSettings alloc] init];
        _leftExpansion = [[MGSwipeExpansionSettings alloc] init];
        _rightExpansion = [[MGSwipeExpansionSettings alloc] init];
    }
    _animationData = [[MGSwipeAnimationData alloc] init];
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:_panRecognizer];
    _panRecognizer.delegate = self;
    _activeExpansion = nil;
    _previusHiddenViews = [NSMutableSet set];
    _swipeState = MGSwipeStateNone;
    _triggerStateChanges = YES;
    _allowsSwipeWhenTappingButtons = YES;
    _preservesSelectionStatus = NO;
    _allowsOppositeSwipe = YES;
    _firstSwipeState = MGSwipeStateNone;
    
}

-(void) cleanViews
{
    [self hideSwipeAnimated:NO];
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    if (_swipeOverlay) {
        [_swipeOverlay removeFromSuperview];
        _swipeOverlay = nil;
    }
    _leftView = _rightView = nil;
    if (_panRecognizer) {
        _panRecognizer.delegate = nil;
        [self removeGestureRecognizer:_panRecognizer];
        _panRecognizer = nil;
    }
}

- (BOOL)isAppExtension
{
    return [[NSBundle mainBundle].executablePath rangeOfString:@".appex/"].location != NSNotFound;
}


-(BOOL) isRTLLocale
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 9, *)) {
#else
    if ([[UIView class] respondsToSelector:@selector(userInterfaceLayoutDirectionForSemanticContentAttribute:)]) {
#endif
        return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
    }
    else if ([self isAppExtension]) {
        return [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]]==NSLocaleLanguageDirectionRightToLeft;
    } else {
        UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
        return application.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    }
}

-(void) fixRegionAndAccesoryViews
{
    //Fix right to left layout direction for arabic and hebrew languagues
    if (self.bounds.size.width != self.contentView.bounds.size.width && [self isRTLLocale]) {
        _swipeOverlay.frame = CGRectMake(-self.bounds.size.width + self.contentView.bounds.size.width, 0, _swipeOverlay.bounds.size.width, _swipeOverlay.bounds.size.height);
    }
}

-(UIEdgeInsets) getSafeInsets {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11, *)) {
        return self.safeAreaInsets;
    }
    else {
        return UIEdgeInsetsZero;
    }
#else
    return UIEdgeInsetsZero;
#endif
}

-(UIView *) swipeContentView
{
    if (!_swipeContentView) {
        _swipeContentView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _swipeContentView.backgroundColor = [UIColor clearColor];
        _swipeContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _swipeContentView.layer.zPosition = 9;
        [self.contentView addSubview:_swipeContentView];
    }
    return _swipeContentView;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if (_swipeContentView) {
        _swipeContentView.frame = self.contentView.bounds;
    }
    if (_swipeOverlay) {
        CGSize prevSize = _swipeView.bounds.size;
        _swipeOverlay.frame = CGRectMake(0, 0, self.bounds.size.width, self.contentView.bounds.size.height);
        [self fixRegionAndAccesoryViews];
        if (_swipeView.image &&  !CGSizeEqualToSize(prevSize, _swipeOverlay.bounds.size)) {
            //refresh safeInsets in situations like layout change, orientation change, table resize, etc.
            UIEdgeInsets safeInsets = [self getSafeInsets];
            // Refresh safe insets
            if (_leftView) {
                CGFloat width = _leftView.bounds.size.width;
                [_leftView setSafeInset:safeInsets.left extendEdgeButton:_leftSwipeSettings.expandLastButtonBySafeAreaInsets isRTL: [self isRTLLocale]];
                if (_swipeOffset > 0 && _leftView.bounds.size.width != width) {
                    // Adapt offset to the view change size due to safeInsets
                    _swipeOffset += _leftView.bounds.size.width - width;
                }
            }
            if (_rightView) {
                CGFloat width = _rightView.bounds.size.width;
                [_rightView setSafeInset:safeInsets.right extendEdgeButton:_rightSwipeSettings.expandLastButtonBySafeAreaInsets isRTL: [self isRTLLocale]];
                if (_swipeOffset < 0 && _rightView.bounds.size.width != width) {
                    // Adapt offset to the view change size due to safeInsets
                    _swipeOffset -= _rightView.bounds.size.width - width;
                }
            }
            //refresh contentView in situations like layout change, orientation chage, table resize, etc.
            [self refreshContentView];
        }
    }
}

-(void) fetchButtonsIfNeeded
{
    if (_leftButtons.count == 0 && _delegate && [_delegate respondsToSelector:@selector(swipeTableCell:swipeButtonsForDirection:swipeSettings:expansionSettings:)]) {
        _leftButtons = [_delegate swipeTableCell:self swipeButtonsForDirection:MGSwipeDirectionLeftToRight swipeSettings:_leftSwipeSettings expansionSettings:_leftExpansion];
    }
    if (_rightButtons.count == 0 && _delegate && [_delegate respondsToSelector:@selector(swipeTableCell:swipeButtonsForDirection:swipeSettings:expansionSettings:)]) {
        _rightButtons = [_delegate swipeTableCell:self swipeButtonsForDirection:MGSwipeDirectionRightToLeft swipeSettings:_rightSwipeSettings expansionSettings:_rightExpansion];
    }
}

-(void) createSwipeViewIfNeeded
{
    UIEdgeInsets safeInsets = [self getSafeInsets];
    if (!_swipeOverlay) {
        _swipeOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.contentView.bounds.size.height)];
        [self fixRegionAndAccesoryViews];
        _swipeOverlay.hidden = YES;
        _swipeOverlay.backgroundColor = [self backgroundColorForSwipe];
        _swipeOverlay.layer.zPosition = 10; //force render on top of the contentView;
        _swipeView = [[UIImageView alloc] initWithFrame:_swipeOverlay.bounds];
        _swipeView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _swipeView.contentMode = UIViewContentModeCenter;
        _swipeView.clipsToBounds = YES;
        [_swipeOverlay addSubview:_swipeView];
        [self.contentView addSubview:_swipeOverlay];
    }
    
    [self fetchButtonsIfNeeded];
    if (!_leftView && _leftButtons.count > 0) {
        _leftSwipeSettings.allowsButtonsWithDifferentWidth = _leftSwipeSettings.allowsButtonsWithDifferentWidth || _allowsButtonsWithDifferentWidth;
        _leftView = [[MGSwipeButtonsView alloc] initWithButtons:_leftButtons direction:MGSwipeDirectionLeftToRight swipeSettings:_leftSwipeSettings safeInset:safeInsets.left];
        _leftView.cell = self;
        _leftView.frame = CGRectMake(-_leftView.bounds.size.width + safeInsets.left * ([self isRTLLocale] ? 1 : -1),
                                     _leftSwipeSettings.topMargin,
                                     _leftView.bounds.size.width,
                                     _swipeOverlay.bounds.size.height - _leftSwipeSettings.topMargin - _leftSwipeSettings.bottomMargin);
        _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [_swipeOverlay addSubview:_leftView];
    }
    if (!_rightView && _rightButtons.count > 0) {
        _rightSwipeSettings.allowsButtonsWithDifferentWidth = _rightSwipeSettings.allowsButtonsWithDifferentWidth || _allowsButtonsWithDifferentWidth;
        _rightView = [[MGSwipeButtonsView alloc] initWithButtons:_rightButtons direction:MGSwipeDirectionRightToLeft swipeSettings:_rightSwipeSettings safeInset:safeInsets.right];
        _rightView.cell = self;
        _rightView.frame = CGRectMake(_swipeOverlay.bounds.size.width + safeInsets.right * ([self isRTLLocale] ? 1 : -1),
                                      _rightSwipeSettings.topMargin,
                                      _rightView.bounds.size.width,
                                      _swipeOverlay.bounds.size.height - _rightSwipeSettings.topMargin - _rightSwipeSettings.bottomMargin);
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [_swipeOverlay addSubview:_rightView];
    }
    
    // Refresh safeInsets if required
    if (_leftView) {
        [_leftView setSafeInset:safeInsets.left extendEdgeButton:_leftSwipeSettings.expandLastButtonBySafeAreaInsets isRTL: [self isRTLLocale]];
    }
    
    if (_rightView) {
        [_rightView setSafeInset:safeInsets.right extendEdgeButton:_rightSwipeSettings.expandLastButtonBySafeAreaInsets isRTL: [self isRTLLocale]];
    }
}


- (void) showSwipeOverlayIfNeeded
{
    if (_overlayEnabled) {
        return;
    }
    _overlayEnabled = YES;
    
    if (!_preservesSelectionStatus)
        self.selected = NO;
    if (_swipeContentView)
        [_swipeContentView removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCellWillBeginSwiping:)]) {
        [_delegate swipeTableCellWillBeginSwiping:self];
    }
    
    // snapshot cell without separator
    CGSize  cropSize        = CGSizeMake(self.bounds.size.width, self.contentView.bounds.size.height);
    _swipeView.image = [self imageFromView:self cropSize:cropSize];
    
    _swipeOverlay.hidden = NO;
    if (_swipeContentView)
        [_swipeView addSubview:_swipeContentView];
    
    if (!_allowsMultipleSwipe) {
        //input overlay on the whole table
        UITableView * table = [self parentTable];
        if (_tableInputOverlay) {
            [_tableInputOverlay removeFromSuperview];
        }
        _tableInputOverlay = [[MGSwipeTableInputOverlay alloc] initWithFrame:table.bounds];
        _tableInputOverlay.currentCell = self;
        [table addSubview:_tableInputOverlay];
    }

    _previusSelectionStyle = self.selectionStyle;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setAccesoryViewsHidden:YES];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _tapRecognizer.cancelsTouchesInView = YES;
    _tapRecognizer.delegate = self;
    [self addGestureRecognizer:_tapRecognizer];
}

-(void) hideSwipeOverlayIfNeededIncludingReselect: (BOOL) reselectCellIfNeeded
{
    if (!_overlayEnabled) {
        return;
    }
    _overlayEnabled = NO;
    _swipeOverlay.hidden = YES;
    _swipeView.image = nil;
    if (_swipeContentView) {
        [_swipeContentView removeFromSuperview];
        [self.contentView addSubview:_swipeContentView];
    }
    
    if (_tableInputOverlay) {
        [_tableInputOverlay removeFromSuperview];
        _tableInputOverlay = nil;
    }

    if (reselectCellIfNeeded) {
        self.selectionStyle = _previusSelectionStyle;
        NSArray * selectedRows = self.parentTable.indexPathsForSelectedRows;
        if ([selectedRows containsObject:[self.parentTable indexPathForCell:self]]) {
            self.selected = NO; //Hack: in some iOS versions setting the selected property to YES own isn't enough to force the cell to redraw the chosen selectionStyle
            self.selected = YES;
        }
    }
    [self setAccesoryViewsHidden:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCellWillEndSwiping:)]) {
        [_delegate swipeTableCellWillEndSwiping:self];
    }
    
    if (_tapRecognizer) {
        [self removeGestureRecognizer:_tapRecognizer];
        _tapRecognizer = nil;
    }
}

-(void) refreshContentView
{
    CGFloat currentOffset = _swipeOffset;
    BOOL prevValue = _triggerStateChanges;
    _triggerStateChanges = NO;
    self.swipeOffset = 0;
    self.swipeOffset = currentOffset;
    _triggerStateChanges = prevValue;
}

-(void) refreshButtons: (BOOL) usingDelegate
{
    if (usingDelegate) {
        self.leftButtons = @[];
        self.rightButtons = @[];
    }
    if (_leftView) {
        [_leftView removeFromSuperview];
        _leftView = nil;
    }
    if (_rightView) {
        [_rightView removeFromSuperview];
        _rightView = nil;
    }
    [self createSwipeViewIfNeeded];
    [self refreshContentView];
}

#pragma mark Handle Table Events

-(void) willMoveToSuperview:(UIView *)newSuperview;
{
    if (newSuperview == nil) { //remove the table overlay when a cell is removed from the table
        [self hideSwipeOverlayIfNeededIncludingReselect:false];
    }
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    [self cleanViews];
    if (_swipeState != MGSwipeStateNone) {
        _triggerStateChanges = YES;
        [self updateState:MGSwipeStateNone];
    }
    BOOL cleanButtons = _delegate && [_delegate respondsToSelector:@selector(swipeTableCell:swipeButtonsForDirection:swipeSettings:expansionSettings:)];
    [self initViews:cleanButtons];
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) { //disable swipe buttons when the user sets table editing mode
        self.swipeOffset = 0;
    }
}

-(void) setEditing:(BOOL)editing
{
    [super setEditing:YES];
    if (editing) { //disable swipe buttons when the user sets table editing mode
        self.swipeOffset = 0;
    }
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.hidden && _swipeOverlay && !_swipeOverlay.hidden) {
        //override hitTest to give swipe buttons a higher priority (diclosure buttons can steal input)
        UIView * targets[] = {_leftView, _rightView};
        for (int i = 0; i< 2; ++i) {
            UIView * target = targets[i];
            if (!target) continue;
            
            CGPoint p = [self convertPoint:point toView:target];
            if (CGRectContainsPoint(target.bounds, p)) {
                return [target hitTest:p withEvent:event];
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark Some utility methods

- (UIImage *)imageFromView:(UIView *)view cropSize:(CGSize)cropSize{
    UIGraphicsBeginImageContextWithOptions(cropSize, NO, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void) setAccesoryViewsHidden: (BOOL) hidden
{
    if (@available(iOS 12, *)) {
        // Hide the accessory to prevent blank box being displayed in iOS13 / iOS12
        // (blank area would be overlayed in accessory area when using cell in storyboard view)
        // See: https://github.com/MortimerGoro/MGSwipeTableCell/issues/337
        if (hidden) {
            _previusAccessoryType = self.accessoryType;
            self.accessoryType = UITableViewCellAccessoryNone;
        } else if (self.accessoryType == UITableViewCellAccessoryNone) {
            self.accessoryType = _previusAccessoryType;
            _previusAccessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    if (self.accessoryView) {
        self.accessoryView.hidden = hidden;
    }
    for (UIView * view in self.contentView.superview.subviews) {
        if (view != self.contentView && ([view isKindOfClass:[UIButton class]] || [NSStringFromClass(view.class) rangeOfString:@"Disclosure"].location != NSNotFound)) {
            view.hidden = hidden;
        }
    }
    
    for (UIView * view in self.contentView.subviews) {
        if (view == _swipeOverlay || view == _swipeContentView) continue;
        if (hidden && !view.hidden) {
            view.hidden = YES;
            [_previusHiddenViews addObject:view];
        }
        else if (!hidden && [_previusHiddenViews containsObject:view]) {
            view.hidden = NO;
        }
    }
    
    if (!hidden) {
        [_previusHiddenViews removeAllObjects];
    }
}

-(UIColor *) backgroundColorForSwipe
{
    if (_swipeBackgroundColor) {
        return _swipeBackgroundColor; //user defined color
    }
    else if (self.contentView.backgroundColor && ![self.contentView.backgroundColor isEqual:[UIColor clearColor]]) {
        return self.contentView.backgroundColor;
    }
    else if (self.backgroundColor) {
        return self.backgroundColor;
    }
    return [UIColor clearColor];
}

-(UITableView *) parentTable
{
    UIView * view = self.superview;
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            return (UITableView*) view;
        }
        view = view.superview;
    }
    return nil;
}

-(void) updateState: (MGSwipeState) newState;
{
    if (!_triggerStateChanges || _swipeState == newState) {
        return;
    }
    _swipeState = newState;
    if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:didChangeSwipeState:gestureIsActive:)]) {
        [_delegate swipeTableCell:self didChangeSwipeState:_swipeState gestureIsActive: self.isSwipeGestureActive] ;
    }
}

#pragma mark Swipe Animation

- (void)setSwipeOffset:(CGFloat) newOffset;
{
    CGFloat sign = newOffset > 0 ? 1.0 : -1.0;
    MGSwipeButtonsView * activeButtons = sign < 0 ? _rightView : _leftView;
    MGSwipeSettings * activeSettings = sign < 0 ? _rightSwipeSettings : _leftSwipeSettings;
  
    if(activeSettings.enableSwipeBounces) {
        _swipeOffset = newOffset;

        CGFloat maxUnbouncedOffset = sign * activeButtons.bounds.size.width;
        
        if ((sign > 0 && newOffset > maxUnbouncedOffset) || (sign < 0 && newOffset < maxUnbouncedOffset)) {
            _swipeOffset = maxUnbouncedOffset + (newOffset - maxUnbouncedOffset) * activeSettings.swipeBounceRate;
        }
    }
    else {
        CGFloat maxOffset = sign * activeButtons.bounds.size.width;
        _swipeOffset = sign > 0 ? MIN(newOffset, maxOffset) : MAX(newOffset, maxOffset);
    }
    CGFloat offset = fabs(_swipeOffset);
  
  
    if (!activeButtons || offset == 0) {
        if (_leftView)
            [_leftView endExpansionAnimated:NO];
        if (_rightView)
            [_rightView endExpansionAnimated:NO];
        [self hideSwipeOverlayIfNeededIncludingReselect:true];
        _targetOffset = 0;
        [self updateState:MGSwipeStateNone];
        return;
    }
    else {
        [self showSwipeOverlayIfNeeded];
        CGFloat swipeThreshold = activeSettings.threshold;
        BOOL keepButtons = activeSettings.keepButtonsSwiped;
        _targetOffset = keepButtons && offset > activeButtons.bounds.size.width * swipeThreshold ? activeButtons.bounds.size.width * sign : 0;
    }
    
    BOOL onlyButtons = activeSettings.onlySwipeButtons;
    UIEdgeInsets safeInsets = [self getSafeInsets];
    CGFloat safeInset = [self isRTLLocale] ? safeInsets.right :  -safeInsets.left;
    _swipeView.transform = CGAffineTransformMakeTranslation(safeInset + (onlyButtons ? 0 : _swipeOffset), 0);
    
    //animate existing buttons
    MGSwipeButtonsView* but[2] = {_leftView, _rightView};
    MGSwipeSettings* settings[2] = {_leftSwipeSettings, _rightSwipeSettings};
    MGSwipeExpansionSettings * expansions[2] = {_leftExpansion, _rightExpansion};
    
    for (int i = 0; i< 2; ++i) {
        MGSwipeButtonsView * view = but[i];
        if (!view) continue;

        //buttons view position
        CGFloat translation = MIN(offset, view.bounds.size.width) * sign + settings[i].offset * sign;
        view.transform = CGAffineTransformMakeTranslation(translation, 0);

        if (view != activeButtons) continue; //only transition if active (perf. improvement)
        bool expand = expansions[i].buttonIndex >= 0 && offset > view.bounds.size.width * expansions[i].threshold;
        if (expand) {
            [view expandToOffset:offset settings:expansions[i]];
            _targetOffset = expansions[i].fillOnTrigger ? self.bounds.size.width * sign : 0;
            _activeExpansion = view;
            [self updateState:i ? MGSwipeStateExpandingRightToLeft : MGSwipeStateExpandingLeftToRight];
        }
        else {
            [view endExpansionAnimated:YES];
            _activeExpansion = nil;
            CGFloat t = MIN(1.0f, offset/view.bounds.size.width);
            [view transition:settings[i].transition percent:t];
            [self updateState:i ? MGSwipeStateSwipingRightToLeft : MGSwipeStateSwipingLeftToRight];
        }
    }
}

-(void) hideSwipeAnimated: (BOOL) animated completion:(void(^)(BOOL finished)) completion
{
    MGSwipeAnimation * animation = animated ? (_swipeOffset > 0 ? _leftSwipeSettings.hideAnimation: _rightSwipeSettings.hideAnimation) : nil;
    [self setSwipeOffset:0 animation:animation completion:completion];
}

-(void) hideSwipeAnimated: (BOOL) animated
{
    [self hideSwipeAnimated:animated completion:nil];
}

-(void) showSwipe: (MGSwipeDirection) direction animated: (BOOL) animated
{
    [self showSwipe:direction animated:animated completion:nil];
}

-(void) showSwipe: (MGSwipeDirection) direction animated: (BOOL) animated completion:(void(^)(BOOL finished)) completion
{
    [self createSwipeViewIfNeeded];
    _allowSwipeLeftToRight = _leftButtons.count > 0;
    _allowSwipeRightToLeft = _rightButtons.count > 0;
    UIView * buttonsView = direction == MGSwipeDirectionLeftToRight ? _leftView : _rightView;
    
    if (buttonsView) {
        CGFloat s = direction == MGSwipeDirectionLeftToRight ? 1.0 : -1.0;
        MGSwipeAnimation * animation = animated ? (direction == MGSwipeDirectionLeftToRight ? _leftSwipeSettings.showAnimation : _rightSwipeSettings.showAnimation) : nil;
        [self setSwipeOffset:buttonsView.bounds.size.width * s animation:animation completion:completion];
    }
}

-(void) expandSwipe: (MGSwipeDirection) direction animated: (BOOL) animated
{
    CGFloat s = direction == MGSwipeDirectionLeftToRight ? 1.0 : -1.0;
    MGSwipeExpansionSettings* expSetting = direction == MGSwipeDirectionLeftToRight ? _leftExpansion : _rightExpansion;
    
    // only perform animation if there's no pending expansion animation and requested direction has fillOnTrigger enabled
    if(!_activeExpansion && expSetting.fillOnTrigger) {
        [self createSwipeViewIfNeeded];
        _allowSwipeLeftToRight = _leftButtons.count > 0;
        _allowSwipeRightToLeft = _rightButtons.count > 0;
        UIView * buttonsView = direction == MGSwipeDirectionLeftToRight ? _leftView : _rightView;
        
        if (buttonsView) {
            __weak MGSwipeButtonsView * expansionView = direction == MGSwipeDirectionLeftToRight ? _leftView : _rightView;
            __weak MGSwipeTableCell * weakself = self;
            [self setSwipeOffset:buttonsView.bounds.size.width * s * expSetting.threshold * 2 animation:expSetting.triggerAnimation completion:^(BOOL finished){
                [expansionView endExpansionAnimated:YES];
                [weakself setSwipeOffset:0 animated:NO completion:nil];
            }];
        }
    }
}

-(void) animationTick: (CADisplayLink *) timer
{
    if (!_animationData.start) {
        _animationData.start = timer.timestamp;
    }
    CFTimeInterval elapsed = timer.timestamp - _animationData.start;
    bool completed = elapsed >= _animationData.duration;
    if (completed) {
        _triggerStateChanges = YES;
    }
    self.swipeOffset = [_animationData.animation value:elapsed duration:_animationData.duration from:_animationData.from to:_animationData.to];
    
    //call animation completion and invalidate timer
    if (completed){
        [timer invalidate];
        [self invalidateDisplayLink];
    }
}

-(void)invalidateDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
    if (_animationCompletion) {
        void (^callbackCopy)(BOOL finished) = _animationCompletion; //copy to avoid duplicated callbacks
        _animationCompletion = nil;
        callbackCopy(YES);
    }
}

-(void) setSwipeOffset:(CGFloat)offset animated: (BOOL) animated completion:(void(^)(BOOL finished)) completion
{
    MGSwipeAnimation * animation = animated ? [[MGSwipeAnimation alloc] init] : nil;
    [self setSwipeOffset:offset animation:animation completion:completion];
}

-(void) setSwipeOffset:(CGFloat)offset animation: (MGSwipeAnimation *) animation completion:(void(^)(BOOL finished)) completion
{
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    if (_animationCompletion) { //notify previous animation cancelled
        void (^callbackCopy)(BOOL finished) = _animationCompletion; //copy to avoid duplicated callbacks
        _animationCompletion = nil;
        callbackCopy(NO);
    }
    if (offset !=0) {
        [self createSwipeViewIfNeeded];
    }
    
    if (!animation) {
        self.swipeOffset = offset;
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    _animationCompletion = completion;
    _triggerStateChanges = NO;
    _animationData.from = _swipeOffset;
    _animationData.to = offset;
    _animationData.duration = animation.duration;
    _animationData.start = 0;
    _animationData.animation = animation;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark Gestures

-(void) cancelPanGesture
{
    if (_panRecognizer.state != UIGestureRecognizerStateEnded && _panRecognizer.state != UIGestureRecognizerStatePossible) {
        _panRecognizer.enabled = NO;
        _panRecognizer.enabled = YES;
        if (self.swipeOffset) {
            [self hideSwipeAnimated:YES];
        }
    }
}

-(void) tapHandler: (UITapGestureRecognizer *) recognizer
{
    BOOL hide = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:shouldHideSwipeOnTap:)]) {
        hide = [_delegate swipeTableCell:self shouldHideSwipeOnTap:[recognizer locationInView:self]];
    }
    if (hide) {
        [self hideSwipeAnimated:YES];
    }
}

-(CGFloat) filterSwipe: (CGFloat) offset
{
    bool allowed = offset > 0 ? _allowSwipeLeftToRight : _allowSwipeRightToLeft;
    UIView * buttons = offset > 0 ? _leftView : _rightView;
    if (!buttons || ! allowed) {
        offset = 0;
    }
    else if (!_allowsOppositeSwipe && _firstSwipeState == MGSwipeStateSwipingLeftToRight && offset < 0) {
        offset = 0;
    }
    else if (!_allowsOppositeSwipe && _firstSwipeState == MGSwipeStateSwipingRightToLeft && offset > 0 ) {
        offset = 0;
    }
    return offset;
}

-(void) panHandler: (UIPanGestureRecognizer *)gesture
{
    CGPoint current = [gesture translationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self invalidateDisplayLink];

        if (!_preservesSelectionStatus)
            self.highlighted = NO;
        [self createSwipeViewIfNeeded];
        _panStartPoint = current;
        _panStartOffset = _swipeOffset;
        if (_swipeOffset != 0) {
            _firstSwipeState = _swipeOffset > 0 ? MGSwipeStateSwipingLeftToRight : MGSwipeStateSwipingRightToLeft;
        }
        
        if (!_allowsMultipleSwipe) {
            NSArray * cells = [self parentTable].visibleCells;
            for (MGSwipeTableCell * cell in cells) {
                if ([cell isKindOfClass:[MGSwipeTableCell class]] && cell != self) {
                    [cell cancelPanGesture];
                }
            }
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat offset = _panStartOffset + current.x - _panStartPoint.x;
        if (_firstSwipeState == MGSwipeStateNone) {
            _firstSwipeState = offset > 0 ? MGSwipeStateSwipingLeftToRight : MGSwipeStateSwipingRightToLeft;
        }
        self.swipeOffset = [self filterSwipe:offset];
    }
    else {
        __weak MGSwipeButtonsView * expansion = _activeExpansion;
        if (expansion) {
            __weak UIView * expandedButton = [expansion getExpandedButton];
            MGSwipeExpansionSettings * expSettings = _swipeOffset > 0 ? _leftExpansion : _rightExpansion;
            UIColor * backgroundColor = nil;
            if (!expSettings.fillOnTrigger && expSettings.expansionColor) {
                backgroundColor = expansion.backgroundColorCopy; //keep expansion background color
                expansion.backgroundColorCopy = expSettings.expansionColor;
            }
            [self setSwipeOffset:_targetOffset animation:expSettings.triggerAnimation completion:^(BOOL finished){
                if (!finished || self.hidden || !expansion) {
                    return; //cell might be hidden after a delete row animation without being deallocated (to be reused later)
                }
                BOOL autoHide = [expansion handleClick:expandedButton fromExpansion:YES];
                if (autoHide) {
                    [expansion endExpansionAnimated:NO];
                }
                if (backgroundColor && expandedButton) {
                    expandedButton.backgroundColor = backgroundColor;
                }
            }];
        }
        else {
            CGFloat velocity = [_panRecognizer velocityInView:self].x;
            CGFloat inertiaThreshold = 100.0; //points per second
            
            if (velocity > inertiaThreshold) {
                _targetOffset = _swipeOffset < 0 ? 0 : (_leftView  && _leftSwipeSettings.keepButtonsSwiped ? _leftView.bounds.size.width : _targetOffset);
            }
            else if (velocity < -inertiaThreshold) {
                _targetOffset = _swipeOffset > 0 ? 0 : (_rightView && _rightSwipeSettings.keepButtonsSwiped ? -_rightView.bounds.size.width : _targetOffset);
            }
            _targetOffset = [self filterSwipe:_targetOffset];
            MGSwipeSettings * settings = _swipeOffset > 0 ? _leftSwipeSettings : _rightSwipeSettings;
            MGSwipeAnimation * animation = nil;
            if (_targetOffset == 0) {
                animation = settings.hideAnimation;
            }
            else if (fabs(_swipeOffset) > fabs(_targetOffset)) {
                animation = settings.stretchAnimation;
            }
            else {
                animation = settings.showAnimation;
            }
            [self setSwipeOffset:_targetOffset animation:animation completion:nil];
        }
        
        _firstSwipeState = MGSwipeStateNone;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == _panRecognizer) {
        
        if (self.isEditing) {
            return NO; //do not swipe while editing table
        }
        
        CGPoint translation = [_panRecognizer translationInView:self];
        if (fabs(translation.y) > fabs(translation.x)) {
            return NO; // user is scrolling vertically
        }
        if (_swipeView) {
            CGPoint point = [_tapRecognizer locationInView:_swipeView];
            if (!CGRectContainsPoint(_swipeView.bounds, point)) {
                return _allowsSwipeWhenTappingButtons; //user clicked outside the cell or in the buttons area
            }
        }
        
        if (_swipeOffset != 0.0) {
            return YES; //already swiped, don't need to check buttons or canSwipe delegate
        }
        
        //make a decision according to existing buttons or using the optional delegate
        if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:canSwipe:fromPoint:)]) {
            CGPoint point = [_panRecognizer locationInView:self];
            _allowSwipeLeftToRight = [_delegate swipeTableCell:self canSwipe:MGSwipeDirectionLeftToRight fromPoint:point];
            _allowSwipeRightToLeft = [_delegate swipeTableCell:self canSwipe:MGSwipeDirectionRightToLeft fromPoint:point];
        }
        else if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:canSwipe:)]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _allowSwipeLeftToRight = [_delegate swipeTableCell:self canSwipe:MGSwipeDirectionLeftToRight];
            _allowSwipeRightToLeft = [_delegate swipeTableCell:self canSwipe:MGSwipeDirectionRightToLeft];
            #pragma clang diagnostic pop
        }
        else {
            [self fetchButtonsIfNeeded];
            _allowSwipeLeftToRight = _leftButtons.count > 0;
            _allowSwipeRightToLeft = _rightButtons.count > 0;
        }
        
        return (_allowSwipeLeftToRight && translation.x > 0) || (_allowSwipeRightToLeft && translation.x < 0);
    }
    else if (gestureRecognizer == _tapRecognizer) {
        CGPoint point = [_tapRecognizer locationInView:_swipeView];
        return CGRectContainsPoint(_swipeView.bounds, point);
    }
    return YES;
}

-(BOOL) isSwipeGestureActive
{
    return _panRecognizer.state == UIGestureRecognizerStateBegan || _panRecognizer.state == UIGestureRecognizerStateChanged;
}

-(void)setSwipeBackgroundColor:(UIColor *)swipeBackgroundColor {
    _swipeBackgroundColor = swipeBackgroundColor;
    if (_swipeOverlay) {
        _swipeOverlay.backgroundColor = swipeBackgroundColor;
    }
}

#pragma mark Accessibility

- (NSInteger)accessibilityElementCount {
    return _swipeOffset == 0 ? [super accessibilityElementCount] : 1;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return _swipeOffset == 0  ? [super accessibilityElementAtIndex:index] : self.contentView;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return _swipeOffset == 0  ? [super indexOfAccessibilityElement:element] : 0;
}


@end
