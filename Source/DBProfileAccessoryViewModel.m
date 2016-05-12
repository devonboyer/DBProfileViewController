//
//  DBProfileAccessoryViewModel.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewModel.h"
#import "DBProfileAccessoryView.h"
#import "DBProfileAccessoryViewLayoutAttributes.h"
#import "DBProfileLayoutAttributeBinding.h"

@interface DBProfileAccessoryViewModel () <DBProfileLayoutAttributeBindingDelegate>

@property (nonatomic) NSArray<DBProfileLayoutAttributeBinding *> *bindings;

@end

@implementation DBProfileAccessoryViewModel

- (instancetype)initWithAccessoryView:(DBProfileAccessoryView *)accessoryView
                     layoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes {
    self = [super init];
    if (self) {
        _accessoryView = accessoryView;
        _layoutAttributes = layoutAttributes;
    }
    return self;
}

- (void)dealloc
{
    [self unbind];
}

- (NSString *)representedAccessoryKind {
    return self.layoutAttributes.representedAccessoryKind;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;
    DBProfileAccessoryViewModel *otherObject = (DBProfileAccessoryViewModel *)object;
    return self.representedAccessoryKind == otherObject.representedAccessoryKind;
}

#pragma mark - Binding

- (void)addBinding:(DBProfileLayoutAttributeBinding *)binding
{
    [self addBindings:@[binding]];
}

- (void)addBindings:(NSArray<DBProfileLayoutAttributeBinding *> *)bindings
{
    NSMutableArray *mutableBindings = [self.bindings mutableCopy] ?: [NSMutableArray array];
    [mutableBindings addObjectsFromArray:bindings];
    self.bindings = mutableBindings;
    [self bind];
}

- (void)bind
{
    for (DBProfileLayoutAttributeBinding *binding in self.bindings) {
        [binding bind];
    }
}

- (void)unbind
{
    for (DBProfileLayoutAttributeBinding *binding in self.bindings) {
        [binding unbind];
    }
}

#pragma mark - DBProfileLayoutAttributeBindingDelegate

- (void)binding:(DBProfileLayoutAttributeBinding *)binding valueDidChange:(id)newValue fromValue:(id)oldValue
{
    if ([self.updater respondsToSelector:@selector(updateLayoutAttributeFromValue:toValue:forAccessoryViewModel:)]) {
        [self.updater updateLayoutAttributeFromValue:oldValue toValue:newValue forAccessoryViewModel:self];
    }
}

@end
