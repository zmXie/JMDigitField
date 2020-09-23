//
//  JMDigitField.h
//  JMDigitField
//
//  Created by xzm on 2020/9/23.
//  数字输入框

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JMDigitView;

@interface JMDigitField : UIControl <UIKeyInput, UITextInput>

/**
 初始化一个数字输入框

 @param initBlock 传入一个初始化 digit view 的 block
 @param count 数字位数
 @param leading 第一个数字位距离左侧边距
 @param tailing 最后一个数字位距离右侧边距
 @param weaken 取消高亮时的动作
 @param highlight 设置高亮时的动作
 @param complete 输入框被填满时的动作
 @return returns an instance of WGDigitField
 */
- (instancetype)initWithDigitViewInitBlock:(JMDigitView * (^)(NSInteger index))initBlock
                            numberOfDigits:(NSUInteger)count
                               leadSpacing:(CGFloat)leading
                               tailSpacing:(CGFloat)tailing
                               weakenBlock:(void (^_Nullable)(JMDigitView *digitView))weaken
                          highlightedBlock:(void (^_Nullable)(JMDigitView *digitView))highlight
                         fillCompleteBlock:(void (^_Nullable)(JMDigitField *digitField, NSArray<JMDigitView *> *digitViewArray, NSString *text))complete;

/**
 当前内容
 */
@property (nonatomic, copy) NSString *text;

@end


@interface JMDigitView : UIView

- (instancetype)initWithBackgroundView:(UIView *)view
                             digitFont:(UIFont *)font
                            digitColor:(UIColor *)color;

/**
 是否有内容
 */
@property (nonatomic, assign, readonly) BOOL hasText;
/**
 数字位索引
 */
@property (nonatomic, assign) NSUInteger index;
/**
 内容
 */
@property (nonatomic, copy) NSString *text;
/**
 背景 view
 */
@property (nonatomic, strong, readonly) UIView *backgroundView;
/**
 显示内容的 label
 */
@property (nonatomic, strong, readonly) UILabel *digitLabel;

- (void)inputFlagShow:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
