//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
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

@import WireDataModel;

NS_ASSUME_NONNULL_BEGIN

@protocol AccentColorProvider <NSObject>
@property (nonatomic, readonly) UIColor *accentColor;
@end

@interface UIColor (DefaultAccentColor)

@property (class, readonly, strong) UIColor *defaultAccentColor;

@end

@implementation UIColor (DefaultAccentColor)

+ (UIColor *)defaultAccentColor {
    return [UIColor lightGrayColor];
}

@end

@interface ZMUser (AccentColorProvider) <AccentColorProvider>
@end

@interface ZMSearchUser (AccentColorProvider) <AccentColorProvider>
@end

NS_ASSUME_NONNULL_END
