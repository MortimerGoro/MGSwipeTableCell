/*
 * MGSwipeTableCell is licensed under MIT licensed. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
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
    if (_currentCell && CGRectContainsPoint(_currentCell.bounds, [self convertPoint:point toView:_currentCell])) {
        return nil;
    }
    [_currentCell hideSwipeAnimated:YES];
    return self;
}

@end

#pragma mark Button Container View and transitions

@interface MGSwipeButtonsView : UIView
@property (nonatomic, weak) MGSwipeTableCell * cell;
@end

@implementation MGSwipeButtonsView
{
    NSArray * buttons;
    UIView * container;
    BOOL fromLeft;
    UIView * expandedButton;
    CGFloat expansionOffset;
    BOOL autoHideExpansion;
}

#pragma mark Layout

-(instancetype) initWithButtons:(NSArray*) buttonsArray direction:(MGSwipeDirection) direction
{
    CGSize maxSize = CGSizeZero;
    for (UIView * button in buttonsArray) {
        maxSize.width = MAX(maxSize.width, button.bounds.size.width);
        maxSize.height = MAX(maxSize.height, button.bounds.size.height);
    }
    
    if (self = [super initWithFrame:CGRectMake(0, 0, maxSize.width * buttonsArray.count, maxSize.height)]) {
        fromLeft = direction == MGSwipeDirectionLeftToRight;
        container = [[UIView alloc] initWithFrame:self.bounds];
        container.clipsToBounds = YES;
        container.backgroundColor = [UIColor clearColor];
        [self addSubview:container];
        buttons = fromLeft ? buttonsArray: [[buttonsArray reverseObjectEnumerator] allObjects];
        for (UIView * button in buttons) {
            if ([button isKindOfClass:[UIButton class]]) {
                [(UIButton *)button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            button.frame = CGRectMake(0, 0, maxSize.width, maxSize.height);
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [container insertSubview:button atIndex: fromLeft ? 0: container.subviews.count];
        }
        [self resetButtons];
    }
    return self;
}

-(void) resetButtons
{
    int index = 0;
    for (UIView * button in buttons) {
        button.frame = CGRectMake(index * button.bounds.size.width, 0, button.bounds.size.width, self.bounds.size.height);
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        index++;
    }
}

-(void) layoutExpansion: (CGFloat) offset
{
    expansionOffset = offset;
    container.frame = CGRectMake(fromLeft ? 0: self.bounds.size.width - offset, 0, offset, self.bounds.size.height);
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if (expandedButton) {
        [self layoutExpansion:expansionOffset];
    }
    else {
        container.frame = self.bounds;
    }
}

-(void) expandToOffset:(CGFloat) offset button:(NSInteger) index
{
    if (index < 0 || index>= buttons.count) {
        return;
    }
    if (!expandedButton) {
        expandedButton = [buttons objectAtIndex: fromLeft ? index : buttons.count - index - 1];
        container.backgroundColor = expandedButton.backgroundColor;
        [UIView animateWithDuration:0.2 animations:^{
            for (UIView * button in buttons) {
                button.hidden = YES;
            }
            expandedButton.hidden = NO;
            if (fromLeft) {
                expandedButton.frame = CGRectMake(container.bounds.size.width - expandedButton.bounds.size.width, 0, expandedButton.bounds.size.width, expandedButton.bounds.size.height);
                expandedButton.autoresizingMask|= UIViewAutoresizingFlexibleLeftMargin;
            }
            else {
                expandedButton.frame = CGRectMake(0, 0, expandedButton.bounds.size.width, expandedButton.bounds.size.height);
                expandedButton.autoresizingMask|= UIViewAutoresizingFlexibleRightMargin;
            }

        }];
    }
    
    [self layoutExpansion:offset];
}

-(void) endExpansioAnimated:(BOOL) animated
{
    if (expandedButton) {
        [UIView animateWithDuration: animated ? 0.2 : 0.0 animations:^{
            container.frame = self.bounds;
            [self resetButtons];
            expandedButton = nil;
        } completion:^(BOOL finished) {
            container.backgroundColor = [UIColor clearColor];
            for (UIView * view in buttons) {
                view.hidden = NO;
            }
        }];
    }
}

-(UIView*) getExpandedButton
{
    return expandedButton;
}

#pragma mark Trigger Actions

-(void) handleClick: (id) sender fromExpansion:(BOOL) fromExpansion
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
        NSInteger index = [buttons indexOfObject:sender];
        if (!fromLeft) {
            index = buttons.count - index - 1; //right buttons are reversed
        }
        autoHide|= [_cell.delegate swipeTableCell:_cell tappedButtonAtIndex:index direction:fromLeft ? MGSwipeDirectionLeftToRight : MGSwipeDirectionRightToLeft fromExpansion:fromExpansion];
    }
    
    if (fromExpansion) {
        expandedButton = nil;
        _cell.swipeOffset = 0;
    }
    else if (autoHide) {
        [_cell hideSwipeAnimated:YES];
    }

}
//button listener
-(void) buttonClicked: (id) sender
{
    [self handleClick:sender fromExpansion:NO];
}


#pragma mark Transitions

-(void) transitionStatic:(CGFloat) t
{
    const CGFloat dx = self.bounds.size.width * t;
    for (NSInteger i = buttons.count - 1; i >=0 ; --i) {
        UIView * button = [buttons objectAtIndex:i];
        const CGFloat x = fromLeft ? self.bounds.size.width - dx + button.bounds.size.width * i : dx - button.bounds.size.width * (buttons.count - i);
        button.frame = CGRectMake(x, 0, button.bounds.size.width, button.bounds.size.height);
    }
}

-(void) transitionDrag:(CGFloat) t
{
    //No Op, nothing to do ;)
}

-(void) transitionClip:(CGFloat) t
{
    const CGFloat dx = (self.bounds.size.width * t) / (buttons.count * 2);
    for (int i = 0; i < buttons.count; ++i) {
        UIView * button = [buttons objectAtIndex:i];
        CAShapeLayer * maskLayer = [[CAShapeLayer alloc] init];
        const CGSize size = button.bounds.size;
        CGRect maskRect = CGRectMake(size.width * 0.5 - dx, 0, dx * 2, size.height);
        CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
        maskLayer.path = path;
        CGPathRelease(path);
        CGFloat ox =  dx * (2 * i + 1) - size.width * 0.5;
        button.frame = CGRectMake(fromLeft ?  self.bounds.size.width * (1-t) + ox: ox, 0, button.bounds.size.width, button.bounds.size.height);
        button.layer.mask = maskLayer;
    }
}

-(void) transtitionFloatBorder:(CGFloat) t
{
    const CGFloat x0 = self.bounds.size.width * (fromLeft ? (1.0 -t) : t);
    CGFloat dx = (self.bounds.size.width * t) / buttons.count;
    for (int i = 0; i < buttons.count; ++i) {
        UIView * button = [buttons objectAtIndex:i];
        const CGFloat x = fromLeft ? x0 + dx * (i + 1) - button.bounds.size.width : x0 - dx  * (buttons.count - i);
        button.frame = CGRectMake(x , 0, button.bounds.size.width, button.bounds.size.height);
    }
}

-(void) transition3D:(CGFloat) t
{
    const CGFloat invert = fromLeft ? 1.0 : -1.0;
    const CGFloat angle = M_PI_2 * (1.0 - t) * invert;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/400.0f; //perspective 1/z
    const CGFloat dx = -container.bounds.size.width * 0.5 * invert;
    const CGFloat offset = dx * 2 * (1.0 - t);
    transform = CATransform3DTranslate(transform, dx - offset, 0, 0);
    transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0);
    transform = CATransform3DTranslate(transform, -dx, 0, 0);
    container.layer.transform = transform;
}

-(void) transition:(MGSwipeTransition) mode percent:(CGFloat) t
{
    switch (mode) {
        case MGSwipeTransitionStatic: [self transitionStatic:t]; break;
        case MGSwipeTransitionDrag: [self transitionDrag:t]; break;
        case MGSwipeTransitionClipCenter: [self transitionClip:t]; break;
        case MGSwipeTransitionBorder: [self transtitionFloatBorder:t]; break;
        case MGSwipeTransition3D: [self transition3D:t]; break;
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
    }
    return self;
}
@end

@implementation MGSwipeExpansionSettings
-(instancetype) init
{
    if (self = [super init]) {
        self.buttonIndex = -1;
        self.threshold = 1.3;
    }
    return self;
}
@end

typedef struct MGSwipeAnimationData {
    CGFloat from;
    CGFloat to;
    CFTimeInterval duration;
    CFTimeInterval start;
} MGSwipeAnimationData;


#pragma mark MGSwipeTableCell Implementation

@implementation MGSwipeTableCell
{
    UITapGestureRecognizer * tapRecognizer;
    UIPanGestureRecognizer * panRecognizer;
    CGPoint panStartPoint;
    CGFloat panStartOffset;
    CGFloat targetOffset;
    
    UIView * swipeOverlay;
    UIView * swipeView;
    MGSwipeButtonsView * leftView;
    MGSwipeButtonsView * rightView;
    bool allowSwipeRightToLeft;
    bool allowSwipeLeftToRight;
    __weak MGSwipeButtonsView * activeExpansion;

    MGSwipeTableInputOverlay * tableInputOverlay;
    __weak UITableView * cachedParentTable;
    UITableViewCellSelectionStyle previusSelectionStyle;
    
    MGSwipeAnimationData animationData;
    void (^animationCompletion)();
    CADisplayLink * displayLink;
}

#pragma mark View creation & layout

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

-(void) awakeFromNib
{
    [self initViews];
}

-(void) dealloc
{
    [self removeInputOverlayIfNeeded];
}

-(void) initViews
{
    _leftButtons = [NSArray array];
    _rightButtons = [NSArray array];
    _leftSwipeSettings = [[MGSwipeSettings alloc] init];
    _rightSwipeSettings = [[MGSwipeSettings alloc] init];
    _leftExpansion = [[MGSwipeExpansionSettings alloc] init];
    _rightExpansion = [[MGSwipeExpansionSettings alloc] init];
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
    activeExpansion = nil;
}

-(void) cleanViews
{
    [self hideSwipeAnimated:NO];
    if (displayLink) {
        [displayLink invalidate];
        displayLink = nil;
    }
    if (swipeOverlay) {
        [swipeOverlay removeFromSuperview];
        swipeOverlay = nil;
    }
    leftView = rightView = nil;
    if (panRecognizer) {
        panRecognizer.delegate = nil;
        [self removeGestureRecognizer:panRecognizer];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if (swipeOverlay) {
        swipeOverlay.frame = CGRectMake(0, 0, self.bounds.size.width, self.contentView.bounds.size.height);
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
    if (!swipeOverlay) {
        swipeOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        swipeOverlay.backgroundColor = [self backgroundColorForSwipe];
        swipeOverlay.layer.zPosition = 10; //force render on top of the contentView;
        swipeView = [[UIImageView alloc] initWithImage:[self imageFromView:self]];
        swipeView.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        swipeView.frame = swipeOverlay.bounds;
        swipeView.contentMode = UIViewContentModeCenter;
        swipeView.clipsToBounds = YES;
        [swipeOverlay addSubview:swipeView];
        [self.contentView addSubview:swipeOverlay];
    }
    
    [self fetchButtonsIfNeeded];
    if (!leftView && _leftButtons.count > 0) {
        leftView = [[MGSwipeButtonsView alloc] initWithButtons:_leftButtons direction:MGSwipeDirectionLeftToRight];
        leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        leftView.cell = self;
        leftView.frame = CGRectMake(-leftView.bounds.size.width, 0, leftView.bounds.size.width, swipeOverlay.bounds.size.height);
        [swipeOverlay addSubview:leftView];
    }
    if (!rightView && _rightButtons.count > 0) {
        rightView = [[MGSwipeButtonsView alloc] initWithButtons:_rightButtons direction:MGSwipeDirectionRightToLeft];
        rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        rightView.cell = self;
        rightView.frame = CGRectMake(swipeOverlay.bounds.size.width, 0, rightView.bounds.size.width, swipeOverlay.bounds.size.height);
        [swipeOverlay addSubview:rightView];
    }
}


- (void) addInputOverlayIfNeeded
{
    if (tableInputOverlay) {
        return;
    }
    swipeOverlay.hidden = NO;
    UITableView * table = [self parentTable];
    table.scrollEnabled = NO;
    tableInputOverlay = [[MGSwipeTableInputOverlay alloc] initWithFrame:table.bounds];
    tableInputOverlay.currentCell = self;
    [table addSubview:tableInputOverlay];

    previusSelectionStyle = self.selectionStyle;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setAccesoryViewsHidden:YES];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapRecognizer.cancelsTouchesInView = YES;
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
}

-(void) removeInputOverlayIfNeeded
{
    if (!tableInputOverlay) {
        return;
    }

    swipeOverlay.hidden = YES;
    
    UITableView * table = [self parentTable];
    table.scrollEnabled = YES;
    [tableInputOverlay removeFromSuperview];
    tableInputOverlay = nil;
    
    self.selectionStyle = previusSelectionStyle;
    [self setAccesoryViewsHidden:NO];
    
    if (tapRecognizer) {
        [self removeGestureRecognizer:tapRecognizer];
        tapRecognizer = nil;
    }
}

#pragma mark Handle Table Events

-(void) willMoveToSuperview:(UIView *)newSuperview;
{
    if (newSuperview == nil) { //remove the table overlay when a cell is removed from the table
        [self removeInputOverlayIfNeeded];
    }
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    [self cleanViews];
    [self initViews];
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

#pragma mark Some utility methods

- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void) setAccesoryViewsHidden: (BOOL) hidden
{
    if (self.accessoryView) {
        self.accessoryView.hidden = hidden;
    }
    for (UIView * view in self.contentView.superview.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.hidden = hidden;
        }
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
    else if (self.backgroundColor && ![self.backgroundColor isEqual:[UIColor clearColor]]) {
        return self.backgroundColor;
    }
    return [UIColor whiteColor];
}

-(UITableView *) parentTable
{
    if (cachedParentTable) {
        return cachedParentTable;
    }
    
    UIView * view = self.superview;
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            cachedParentTable = (UITableView*) view;
        }
        view = view.superview;
    }
    return cachedParentTable;
}

#pragma mark Swipe Animation

- (void)setSwipeOffset:(CGFloat) newOffset;
{
    _swipeOffset = newOffset;
    
    CGFloat sign = newOffset > 0 ? 1.0 : -1.0;
    CGFloat offset = fabs(newOffset);
    
    MGSwipeButtonsView * activeButtons = sign < 0 ? rightView : leftView;
    if (!activeButtons || offset == 0) {
        [self removeInputOverlayIfNeeded];
        targetOffset = 0;
    }
    else {
        [self addInputOverlayIfNeeded];
        CGFloat swipeThreshold = sign < 0 ? _rightSwipeSettings.threshold : _leftSwipeSettings.threshold;
        targetOffset = offset > activeButtons.bounds.size.width * swipeThreshold ? activeButtons.bounds.size.width * sign : 0;
    }
    
    swipeView.transform = CGAffineTransformMakeTranslation(newOffset, 0);
    
    //animate existing buttons
    MGSwipeButtonsView* but[2] = {leftView, rightView};
    MGSwipeSettings* settings[2] = {_leftSwipeSettings, _rightSwipeSettings};
    MGSwipeExpansionSettings * expansions[2] = {_leftExpansion, _rightExpansion};
    
    for (int i = 0; i< 2; ++i) {
        MGSwipeButtonsView * view = but[i];
        if (!view) continue;

        //buttons view position
        CGFloat translation = MIN(offset, view.bounds.size.width) * sign;
        view.transform = CGAffineTransformMakeTranslation(translation, 0);

        if (view != activeButtons) continue; //only transition if active (perf. improvement)
        bool expand = expansions[i].buttonIndex >= 0 && offset > view.bounds.size.width * expansions[i].threshold;
        if (expand) {
            [view expandToOffset:offset button:expansions[i].buttonIndex];
            targetOffset = expansions[i].fillOnTrigger ? self.contentView.bounds.size.width * sign : 0;
            activeExpansion = view;
        }
        else {
            [view endExpansioAnimated:YES];
            activeExpansion = nil;
            CGFloat t = MIN(1.0f, offset/view.bounds.size.width);
            [view transition:settings[i].transition percent:t];
        }
    }
}


-(void) updateSwipe: (CGFloat) offset
{
    bool allowed = offset > 0 ? allowSwipeLeftToRight : allowSwipeRightToLeft;
    UIView * buttons = offset > 0 ? leftView : rightView;
    if (!buttons || ! allowed) {
        offset = 0;
    }
    self.swipeOffset = offset;
}

-(void) hideSwipeAnimated: (BOOL) animated
{
    [self setSwipeOffset:0 animated:animated completion:nil];
}

-(void) showSwipe: (MGSwipeDirection) direction animated: (BOOL) animated
{
    [self createSwipeViewIfNeeded];
    UIView * buttonsView = direction == MGSwipeDirectionLeftToRight ? leftView : rightView;
    
    if (buttonsView) {
        CGFloat s = direction == MGSwipeDirectionLeftToRight ? 1.0 : -1.0;
        [self setSwipeOffset:buttonsView.bounds.size.width * s animated:animated completion:nil];
    }
}

-(void) animationTick: (CADisplayLink *) timer
{
    if (!animationData.start) {
        animationData.start = timer.timestamp;
    }
    CFTimeInterval elapsed = timer.timestamp - animationData.start;
    CGFloat t = MIN(elapsed/animationData.duration, 1.0f);
    bool completed = t>=1.0f;
    //CubicEaseOut interpolation
    t--;
    self.swipeOffset = (t * t * t + 1.0) * (animationData.to - animationData.from) + animationData.from;
    //call animation completion and invalidate timer
    if (completed){
        [timer invalidate];
        displayLink = nil;
        if (animationCompletion) {
            animationCompletion();
        }
    }
}
-(void) setSwipeOffset:(CGFloat)offset animated: (BOOL) animated completion:(void(^)()) completion
{
    animationCompletion = completion;
    if (displayLink) {
        [displayLink invalidate];
        displayLink = nil;
    }
    
    if (!animated) {
        self.swipeOffset = offset;
        return;
    }
    
    animationData.from = _swipeOffset;
    animationData.to = offset;
    animationData.duration = 0.3;
    animationData.start = 0;
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

#pragma mark Gestures

-(void) tapHandler: (UITapGestureRecognizer *) recognizer
{
    [self hideSwipeAnimated:YES];
}

-(void) panHandler: (UIPanGestureRecognizer *)gesture
{
    CGPoint current = [gesture translationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.highlighted = NO;
        self.selected = NO;
        [self createSwipeViewIfNeeded];
        panStartPoint = current;
        panStartOffset = _swipeOffset;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat offset = panStartOffset + current.x - panStartPoint.x;
        [self updateSwipe:offset];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        MGSwipeButtonsView * expansion = activeExpansion;
        if (expansion) {
            UIView * expandedButton = [expansion getExpandedButton];
            [self setSwipeOffset:targetOffset animated:YES completion:^{
                [expansion handleClick:expandedButton fromExpansion:YES];
            }];
        }
        else {
            [self setSwipeOffset:targetOffset animated:YES completion:nil];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == panRecognizer) {
        
        if (self.isEditing) {
            return NO; //do not swipe while editing table
        }
        
        CGPoint translation = [panRecognizer translationInView:self];
        if (fabs(translation.y) > fabs(translation.x)) {
            return NO; // user is scrolling vertically
        }
        if (swipeView) {
            CGPoint point = [tapRecognizer locationInView:swipeView];
            if (!CGRectContainsPoint(swipeView.bounds, point)) {
                return NO; //user clicked outside the cell or in the buttons area
            }
        }
        
        if (_swipeOffset != 0.0) {
            return YES; //already swipped, don't need to check buttons or canSwipe delegate
        }
        
        //make a decision according to existing buttons or using he optional delegate
        if (_delegate && [_delegate respondsToSelector:@selector(swipeTableCell:canSwipe:)]) {
            allowSwipeLeftToRight = [_delegate swipeTableCell:self canSwipe:MGSwipeDirectionLeftToRight];
            allowSwipeRightToLeft = [_delegate swipeTableCell:self canSwipe:MGSwipeDirectionRightToLeft];
        }
        else {
            [self fetchButtonsIfNeeded];
            allowSwipeLeftToRight = _leftButtons.count > 0;
            allowSwipeRightToLeft = _rightButtons.count > 0;
        }
        
        return (allowSwipeLeftToRight && translation.x > 0) || (allowSwipeRightToLeft && translation.x < 0);
    }
    else if (gestureRecognizer == tapRecognizer) {
        CGPoint point = [tapRecognizer locationInView:swipeView];
        return CGRectContainsPoint(swipeView.bounds, point);
    }
    return YES;
}

@end
