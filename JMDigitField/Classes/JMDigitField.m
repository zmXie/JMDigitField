//
//  JMDigitField.m
//  JMDigitField
//
//  Created by xzm on 2020/9/23.
//

#import "JMDigitField.h"
#import <Masonry/Masonry.h>

typedef void(^JMDigitFieldFillCompleteBlock) (JMDigitField * digitFiled, NSArray<id> *digitViewArray, NSString *text);
typedef void(^JMDigitFieldUIChangeBlock) (id digitView);

@interface JMDigitField ()

@property (nonatomic, strong) NSMutableArray<JMDigitView *> *digitViewArray;
/**
 当前输入的位置
 */
@property (nonatomic, assign) NSInteger currentIndex;
/**
 输入框被填满后调用
 */
@property (nonatomic, copy) JMDigitFieldFillCompleteBlock completionBlock;
/**
 取消高亮时调用
 */
@property (nonatomic, copy) JMDigitFieldUIChangeBlock weakenBlock;
/**
 设置高亮时调用
 */
@property (nonatomic, copy) JMDigitFieldUIChangeBlock highlightBlock;
/**
 数字位数
 */
@property (nonatomic, assign) NSUInteger numberOfDigits;

@end

@implementation JMDigitField
@synthesize text = _text;

/**
 初始化一个数字输入框

 @param initBlock 传入一个初始化 digit view 的 block
 @param count 数字位数
 @param leading 第一个数字位距离左侧边距
 @param tailing 最后一个数字位距离右侧边距
 @param weaken 取消高亮时的动作
 @param highlight 设置高亮时的动作
 @param complete 输入框被填满时的动作
 @return returns an instance of JMDigitField
 */
- (instancetype)initWithDigitViewInitBlock:(JMDigitView * (^)(NSInteger index))initBlock
                            numberOfDigits:(NSUInteger)count
                               leadSpacing:(CGFloat)leading
                               tailSpacing:(CGFloat)tailing
                               weakenBlock:(void (^_Nullable)(JMDigitView *digitView))weaken
                          highlightedBlock:(void (^_Nullable)(JMDigitView *digitView))highlight
                         fillCompleteBlock:(void (^_Nullable)(JMDigitField *digitField, NSArray<JMDigitView *> *digitViewArray, NSString *text))complete
{
    NSAssert(count != 0, @"count必须大于0");
    if (self = [super initWithFrame:CGRectZero]) {
        CGFloat width = 0.f;
        CGFloat height = 0.f;
        for (int i = 0; i < count; i++) {
            JMDigitView *view = initBlock(i);
            view.index = i;
            
            width = view.frame.size.width;
            height = view.frame.size.height;
            
            [self.digitViewArray addObject:view];
            [self addSubview:view];
        }
        
        if (count == 1) {
            [self.digitViewArray.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.equalTo(@(width));
                make.height.equalTo(@(height));
            }];
        } else {
            [self.digitViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:width leadSpacing:leading tailSpacing:tailing];
            [self.digitViewArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.width.equalTo(@(width));
                make.height.equalTo(@(height));
            }];
        }
        
        self.completionBlock = [complete copy];
        self.weakenBlock = [weaken copy];
        self.highlightBlock = [highlight copy];
        self.numberOfDigits = count;
    }
    return self;
}

#pragma mark - getter & setter
- (NSString *)text {
    __block NSString *text = @"";
    [self.digitViewArray enumerateObjectsUsingBlock:^(JMDigitView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        text = [text stringByAppendingString:obj.text ?: @""];
    }];
    return text;
}

- (void)setText:(NSString *)text {
    if (text.length == 0) {
        _text = @"";
        [self clearText];
        return;
    }
    if (text.length > self.numberOfDigits) {
        text = [text substringToIndex:self.numberOfDigits];
    }
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9]*$"] evaluateWithObject:text]) {
        return;
    }
    _text = text;
    for (int i = 0; i < text.length; i++) {
        if (i >= self.digitViewArray.count) {
            break;
        }
        NSString *digit = [text substringWithRange:NSMakeRange(i, 1)];
        [self setText:digit atIndex:i];
    }
}

- (NSMutableArray<JMDigitView *> *)digitViewArray {
    if (!_digitViewArray) {
        _digitViewArray = [[NSMutableArray alloc] init];
    }
    return _digitViewArray;
}

- (NSInteger)currentIndex {
    // find first view without text
    __block JMDigitView *view = nil;
    [self.digitViewArray enumerateObjectsUsingBlock:^(JMDigitView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.hasText) {
            view = obj;
            *stop = YES;
        }
    }];
    if (view) {
        return view.index;
    }
    return self.numberOfDigits;
}

#pragma mark - override UIResponder method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    [self refreshHighlightedDigitView];
    self.highlighted = YES;
    [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
    return YES;
}

- (BOOL)resignFirstResponder {
    [self weakenAllDigitView];
    if (self.highlighted) {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
    self.highlighted = NO;
    return [super resignFirstResponder];
}

#pragma mark - UITextInputTraits
- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeNumberPad;
}

- (UITextContentType)textContentType
{
    if (@available(iOS 12.0, *)) {
        return UITextContentTypeOneTimeCode;
    } else {
        return nil;
    }
}

#pragma mark - UIKeyInput
- (void)insertText:(NSString *)text
{
    [self setText:text atIndex:self.currentIndex];
}

- (void)deleteBackward
{
    [self setText:@"" atIndex:self.currentIndex - 1];
}

- (BOOL)hasText
{
    return self.text.length != 0;
}

#pragma mark - private method
- (void)setText:(NSString *)text atIndex:(NSInteger)index
{
    if (index >= self.numberOfDigits || index < 0) {
        return;
    }
    if (self.digitViewArray.count >= index + 1) {
        self.digitViewArray[index].text = text;
        
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        if (self.highlighted) {
            [self refreshHighlightedDigitView];
        }
    }
    if (self.currentIndex == self.numberOfDigits) {
        !self.completionBlock ?: self.completionBlock(self, self.digitViewArray, self.text);
    }
}

- (void)refreshHighlightedDigitView
{
    NSInteger currentIndex = MIN(self.currentIndex, self.numberOfDigits - 1);
    for (JMDigitView *view in self.digitViewArray) {
        if (view.index == currentIndex) {
            !self.highlightBlock ?: self.highlightBlock(view);
        } else {
            !self.weakenBlock ?: self.weakenBlock(view);
        }
    }
}

- (void)weakenAllDigitView {
    for (JMDigitView *view in self.digitViewArray) {
        !self.weakenBlock ?: self.weakenBlock(view);
    }
}

- (void)clearText
{
    [self.digitViewArray enumerateObjectsUsingBlock:^(JMDigitView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.text = @"";
    }];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (self.highlighted) {
        [self refreshHighlightedDigitView];
    }
}

#pragma mark - UITextInput
- (nullable NSString *)textInRange:(UITextRange *)range {
    return nil;
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text {
    return;
}

- (UITextRange *)selectedTextRange {
    return nil;
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    return;
}

- (UITextRange *)markedTextRange {
    return nil;
}

- (NSDictionary<NSAttributedStringKey,id> *)markedTextStyle {
    return nil;
}

- (void)setMarkedTextStyle:(NSDictionary<NSAttributedStringKey,id> *)markedTextStyle {
    return;
}

- (void)setMarkedText:(nullable NSString *)markedText selectedRange:(NSRange)selectedRange {
    return;
}
- (void)unmarkText {
    return;
}

- (UITextPosition *)beginningOfDocument {
    return nil;
}

- (UITextPosition *)endOfDocument {
    return nil;
}

- (nullable UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition {
    return nil;
}

- (nullable UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset {
    return nil;
}

- (nullable UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {
    return nil;
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other {
    return NSOrderedSame;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition {
    return 0;
}

- (id<UITextInputDelegate>)inputDelegate {
    return nil;
}

- (void)setInputDelegate:(id<UITextInputDelegate>)inputDelegate {
    return;
}

- (id<UITextInputTokenizer>)tokenizer {
    return nil;
}

- (nullable UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {
    return nil;
}

- (nullable UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {
    return nil;
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
    return UITextWritingDirectionNatural;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {
    return;
}

- (CGRect)firstRectForRange:(UITextRange *)range {
    return CGRectNull;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectNull;
}

- (NSArray<UITextSelectionRect *> *)selectionRectsForRange:(UITextRange *)range {
    return nil;
}

- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point {
    return nil;
}

- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {
    return nil;
}

- (nullable UITextRange *)characterRangeAtPoint:(CGPoint)point {
    return nil;
}

@end


@interface JMDigitView ()

@property (nonatomic,strong) UIView *inputFlag;

@end

@implementation JMDigitView

- (instancetype)initWithBackgroundView:(UIView *)view
                             digitFont:(UIFont *)font
                            digitColor:(UIColor *)color
{
    NSAssert([view isKindOfClass:UIView.class], @"background必须是UIView");
    if (self = [super initWithFrame:((UIView *)view).frame]) {
        _backgroundView = view;
        
        _digitLabel = [[UILabel alloc] init];
        _digitLabel.font = font;
        _digitLabel.textColor = color;
        _digitLabel.textAlignment = NSTextAlignmentCenter;
        _digitLabel.numberOfLines = 1;
        _digitLabel.backgroundColor = [UIColor clearColor];
        
        [_backgroundView addSubview:_digitLabel];
        [_digitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.backgroundView);
            make.edges.equalTo(self.backgroundView);
        }];
        
        [self addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (BOOL)hasText
{
    return self.digitLabel.text.length != 0;
}

- (NSString *)text
{
    return self.digitLabel.text;
}

- (void)setText:(NSString *)text
{
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[0-9]$"] evaluateWithObject:text] || text.length == 0) {
        self.digitLabel.text = text;
    }
}

- (UIView *)inputFlag
{
    if (!_inputFlag) {
        _inputFlag = [UIView new];
        _inputFlag.layer.cornerRadius = 2;
        _inputFlag.layer.masksToBounds = YES;
        [self.backgroundView addSubview:_inputFlag];
        [_inputFlag mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(2);
            make.centerX.equalTo(self.backgroundView);
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
        }];
    }
    return _inputFlag;
}

- (void)inputFlagShow:(BOOL)show
{
    if ([self hasText]) {
        show = NO;
    }
    self.inputFlag.hidden = !show;
    if (show) {
        self.inputFlag.layer.backgroundColor = ((UIView *)self.backgroundView).layer.borderColor;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 1;
        animation.repeatCount = CGFLOAT_MAX;
        animation.values = @[@(1), @(1), @(0.8),@(0),@(0),@(0.8),@(1)];
        [self.inputFlag.layer addAnimation:animation forKey:@"opacity"];
    } else {
        [self.inputFlag.layer removeAllAnimations];
    }
}


@end
