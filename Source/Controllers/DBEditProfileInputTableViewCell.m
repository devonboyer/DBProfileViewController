//
//  DBEditProfileInputTableViewCell.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-15.
//
//

#import "DBEditProfileInputTableViewCell.h"

@interface DBEditProfileInputTableViewCell ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation DBEditProfileInputTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc] init];
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.delegate = self;
        [self.contentView addSubview:self.textField];
        
        [self.contentView addConstraints:
         @[
           [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1 constant:12],
           [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
           [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.8 constant:0],
           [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]
           ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
