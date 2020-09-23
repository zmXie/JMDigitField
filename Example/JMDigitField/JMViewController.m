//
//  JMViewController.m
//  JMDigitField
//
//  Created by zmXie on 09/23/2020.
//  Copyright (c) 2020 zmXie. All rights reserved.
//

#import "JMViewController.h"
#import <JMDigitField/JMDigitField.h>
#import <Masonry/Masonry.h>

#define DCRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define SCREENWIDTH      [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT     [[UIScreen mainScreen] bounds].size.height

@interface JMViewController ()

@end

@implementation JMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addDigitField];
    [self addDigitField2];
}

- (void)addDigitField
{
    CGFloat s = 14 *SCREENWIDTH/375.f;
    CGFloat w = (SCREENWIDTH - 20*2 - s*5)/6;
    CGFloat h = w * 48/44.f;
    CGSize itemSize = CGSizeMake(w, h);
    
    JMDigitField *codeTf = [[JMDigitField alloc] initWithDigitViewInitBlock:^JMDigitView * _Nonnull(NSInteger index) {
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        background.backgroundColor = [UIColor whiteColor];
        background.layer.borderColor = DCRGBA(221,221,221,1).CGColor;
        background.layer.borderWidth = 1.f;
        return [[JMDigitView alloc] initWithBackgroundView:background digitFont:[UIFont fontWithName:@"PingFangSC-Semibold" size: 24] digitColor:[UIColor blackColor]];
        
    } numberOfDigits:6 leadSpacing:0 tailSpacing:0 weakenBlock:^(JMDigitView * _Nonnull digitView) {
        
        digitView.backgroundView.layer.borderColor = DCRGBA(221,221,221,1).CGColor;
        [digitView inputFlagShow:NO];
        
    } highlightedBlock:^(JMDigitView * _Nonnull digitView) {
        
        digitView.backgroundView.layer.borderColor = DCRGBA(0,127,255,1).CGColor;
        [digitView inputFlagShow:YES];
        
    } fillCompleteBlock:^(JMDigitField * _Nonnull digitField, NSArray<JMDigitView *> * _Nonnull digitViewArray, NSString * _Nonnull text) {
        NSLog(@"text=%@",text);
    }];
    
    [codeTf becomeFirstResponder];
    [self.view addSubview:codeTf];
    [codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(200);
        make.height.mas_equalTo(h);
    }];
}

- (void)addDigitField2
{
    CGFloat s = 14 *SCREENWIDTH/375.f;
    CGFloat w = (SCREENWIDTH - 20*2 - s*5)/6;
    CGFloat h = w * 48/44.f;
    CGSize itemSize = CGSizeMake(w, h);
    
    JMDigitField *codeTf = [[JMDigitField alloc] initWithDigitViewInitBlock:^JMDigitView * _Nonnull(NSInteger index) {
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        background.backgroundColor = [UIColor whiteColor];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, itemSize.height - 1, itemSize.width, 1)];
        line.backgroundColor = DCRGBA(221,221,221,1);
        line.tag = 1;
        [background addSubview:line];
        return [[JMDigitView alloc] initWithBackgroundView:background digitFont:[UIFont fontWithName:@"PingFangSC-Semibold" size: 24] digitColor:[UIColor blackColor]];
        
    } numberOfDigits:6 leadSpacing:0 tailSpacing:0 weakenBlock:^(JMDigitView * _Nonnull digitView) {
        
        [digitView.backgroundView viewWithTag:1].backgroundColor = DCRGBA(221,221,221,1);
        [digitView inputFlagShow:NO];
        
    } highlightedBlock:^(JMDigitView * _Nonnull digitView) {
        
        [digitView.backgroundView viewWithTag:1].backgroundColor = DCRGBA(0,127,255,1);
        [digitView inputFlagShow:YES];
        
    } fillCompleteBlock:^(JMDigitField * _Nonnull digitField, NSArray<JMDigitView *> * _Nonnull digitViewArray, NSString * _Nonnull text) {
        NSLog(@"text=%@",text);
    }];
    
    [codeTf becomeFirstResponder];
    [self.view addSubview:codeTf];
    [codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(300);
        make.height.mas_equalTo(h);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
