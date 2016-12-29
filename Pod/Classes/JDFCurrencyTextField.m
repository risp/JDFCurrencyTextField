//
//  JDFCurrencyTextField.m
//  LivePokerManager2012
//
//  Created by Joe Fryer on 19/01/2014.
//  Copyright (c) 2014 JoeFryer. All rights reserved.
//

#import "JDFCurrencyTextField.h"



@interface JDFCurrencyTextField ()

// Formatter
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;

// Delegate
@property (nonatomic, weak) id<UITextFieldDelegate> realDelegate;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@end



@implementation JDFCurrencyTextField

@synthesize locale = _locale;
@synthesize currencyCode = _currencyCode;

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self formatTextAfterEditing];
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.realDelegate = delegate;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    [super setKeyboardType:UIKeyboardTypeDecimalPad];
}

- (void)setLocale:(NSLocale *)locale
{
    _locale = locale;
    self.currencyFormatter.locale = locale;
}

- (void)setDecimalValue:(NSDecimalNumber *)decimalValue
{
    self.text = [self.decimalFormatter stringFromNumber:decimalValue];
    [self formatTextAfterEditing];
}

- (void)setCurrencyCode:(NSString *)currencyCode {
    _currencyCode = currencyCode;
    self.currencyFormatter.currencyCode = currencyCode;
}

#pragma mark - Getters

- (NSLocale *)locale
{
    if (!_locale) {
        _locale = [NSLocale currentLocale];
    }
    return _locale;
}

- (NSString *)currencyCode
{
    if (!_currencyCode) {
        _currencyCode = @"EUR";
    }
    return _currencyCode;
}

- (NSNumberFormatter *)currencyFormatter
{
    if (!_currencyFormatter) {
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setLocale:self.locale];
        [_currencyFormatter setCurrencyCode:self.currencyCode];
    }
    return _currencyFormatter;
}

- (NSNumberFormatter *)decimalFormatter
{
    if (!_decimalFormatter) {
        _decimalFormatter = [[NSNumberFormatter alloc] init];
        [_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_decimalFormatter setLocale:self.locale];
        [_decimalFormatter setCurrencyCode:self.currencyCode];
    }
    return _decimalFormatter;
}

- (NSDecimalNumber *)decimalValue
{
    NSNumberFormatter *numberFormatter;
    if (self.editing) {
        numberFormatter = self.decimalFormatter;
    } else {
        numberFormatter = self.currencyFormatter;
    }
    return [NSDecimalNumber decimalNumberWithDecimal:[[numberFormatter numberFromString:self.text] decimalValue]];
}


#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    [super setDelegate:self];
    self.keyboardType = UIKeyboardTypeDecimalPad;
    [self formatTextAfterEditing];
    self.keyboardToolbar = [[UIToolbar alloc] init];
    self.keyboardToolbar.barStyle = UIBarStyleDefault;
    self.keyboardToolbar.barTintColor = [UIColor colorWithRed:209/255.0 green:213/255.0 blue:219/255.0 alpha:1.0f];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dismiss-keyboard-icon-filled"] style:UIBarButtonItemStylePlain target:self action:@selector(doneEditing)];
    
    [self.keyboardToolbar setItems:@[space, done] animated:NO];
    [self.keyboardToolbar sizeToFit];
    
    self.inputAccessoryView = self.keyboardToolbar;
}

- (void)doneEditing {
    [self resignFirstResponder];
}

#pragma mark - Internal

- (void)formatTextInPreparationForEditing
{
    NSString *currentString = self.text;
    if (!currentString.length > 0) {
        return;
    }
    
    NSNumber *number = [self.currencyFormatter numberFromString:currentString];
    if (number.doubleValue == 0) {
        super.text = @"";
    } else {
        super.text = [self.decimalFormatter stringFromNumber:number];
    }
}

- (void)formatTextAfterEditing
{
    NSString *currentString = self.text;
    
    NSNumber *number = [self.decimalFormatter numberFromString:currentString];
    if (number.doubleValue == 0) {
        number = [self.currencyFormatter numberFromString:currentString];
        if (!number) {
            number = @0;
        }
    }
    if (currentString.length == 0) {
        number = @0;
    }
    
    if (self.showPlaceHolder && number.doubleValue == 0) {
        super.placeholder = [self.currencyFormatter stringFromNumber:number];
    } else {
        super.text = [self.currencyFormatter stringFromNumber:number];
    }
}


#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self formatTextInPreparationForEditing];
    if ([self.realDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.realDelegate textFieldDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self formatTextAfterEditing];
    if ([self.realDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.realDelegate textFieldDidEndEditing:self];
    }
}


#pragma mark - UITextFieldDelegate forwarding

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.realDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.realDelegate respondsToSelector:aSelector]) {
        return self.realDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
