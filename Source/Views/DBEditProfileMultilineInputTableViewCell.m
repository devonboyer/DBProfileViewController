//
//  DBEditProfileMultilineInputTableViewCell.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-15.
//
//

#import "DBEditProfileMultilineInputTableViewCell.h"

@interface DBEditProfileMultilineInputTableViewCell ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation DBEditProfileMultilineInputTableViewCell

@dynamic delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[UITextView alloc] init];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.scrollEnabled = NO;
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.delegate = self;
        [self.contentView addSubview:self.textView];
        
        [self.contentView addConstraints:
         @[
           [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1 constant:12],
           [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-12],
           [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:6],
           [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-6],
           ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textView.text = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate editProfileMultilineInputTableViewCell:self textViewDidChange:textView];
}


@end
