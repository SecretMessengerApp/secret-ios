// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


#import "StartUIInviteActionBar.h"
#import "IconButton.h"
@import PureLayout;
@import WireExtensionComponents;
#import "Secret-Swift.h"

@interface StartUIInviteActionBar ()

@property (nonatomic) UIVisualEffectView *backgroundView;
@property (nonatomic, readwrite) Button *inviteButton;
@property (nonatomic) NSLayoutConstraint *bottomEdgeConstraint;

@end


@implementation StartUIInviteActionBar

static const CGFloat padding = 12;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor wr_colorFromColorScheme:ColorSchemeColorSearchBarBackground variant:ColorSchemeVariantDark];

        [self createInviteButton];
        [self createConstraints];
        // 高度不需要变化了，去掉键盘监控
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(keyboardFrameWillChange:)
//                                                     name:UIKeyboardWillChangeFrameNotification
//                                                   object:nil];
    }
    return self;
}

///邀请界面需要修改title
- (void)setBtnTitleWith:(NSString *)title{
    [self.inviteButton setTitle:title forState:UIControlStateNormal];
}

- (void)createInviteButton
{
    self.inviteButton = [Button buttonWithStyle:ButtonStyleFull variant:ColorSchemeVariantDark];
    self.inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.inviteButton.titleEdgeInsets = UIEdgeInsetsMake(2, 8, 3, 8);
    [self addSubview:self.inviteButton];
    [self.inviteButton setTitle:NSLocalizedString(@"peoplepicker.invite_more_people", @"") forState:UIControlStateNormal];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, (self.hidden) ? 0 : 56.0f);
}

- (void)createConstraints
{
    [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset: padding];
    [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset: padding*2];
    [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset: padding*2];
    [self.inviteButton autoSetDimension:ALDimensionHeight toSize:28];
    self.bottomEdgeConstraint = [self.inviteButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset: padding];
}

#pragma mark - UIKeyboard notifications

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    CGFloat beginOrigin = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    CGFloat endOrigin = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat diff = beginOrigin - endOrigin;
    [UIView animateWithKeyboardNotification:notification inView:self animations:^(CGRect keyboardFrameInView) {
        self.bottomEdgeConstraint.constant = -padding - (diff > 0 ? 0 : UIScreen.safeArea.bottom);
        [self layoutIfNeeded];
    } completion:nil];
}

@end
