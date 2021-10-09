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




#import "InviteContactsViewController.h"
#import "InviteContactsViewController+Internal.h"
#import "ContactsViewController+Internal.h"
#import "ContactsDataSource.h"
#import "WireSyncEngine+iOS.h"
#import "Secret-Swift.h"

@interface InviteContactsViewController () <ContactsViewControllerDelegate, ContactsViewControllerContentDelegate>
@end

@implementation InviteContactsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.colorSchemeVariant = ColorSchemeVariantLight;
        self.delegate = self;
        self.contentDelegate = self;
        self.dataSource = [[ContactsDataSource alloc] init];
        self.dataSource.searchQuery = @"";
        
        self.title = [NSLocalizedString(@"contacts_ui.title", @"") uppercaseString];

        [self setupStyle];
    }
    
    return self;
}

- (BOOL)sharingContactsRequired
{
    return YES;
}

- (void)inviteUserOrOpenConversation:(ZMSearchUser *)user fromView:(UIView *)view
{
    if (user.isConnected) {
        [ZClientViewController.shared selectWithConversation:user.oneToOneConversation];
    } else if (user.user.isPendingApprovalBySelfUser && ! user.user.isIgnored) {
        [[ZClientViewController shared] selectIncomingContactRequestsAndFocusOnView:YES];
    } else if (user.user.isPendingApprovalByOtherUser && ! user.user.isIgnored) {
        [ZClientViewController.shared selectWithConversation:user.oneToOneConversation];
        
    } else if (user.user != nil && ! user.user.isIgnored && ! user.user.isPendingApprovalByOtherUser) {
        NSString *messageText = [NSString stringWithFormat:NSLocalizedString(@"missive.connection_request.default_message",@"Default connect message to be shown"), user.user.displayName, [ZMUser selfUser].name];
        
        [[ZMUserSession sharedSession] enqueueChanges:^{
            [user connectWithMessage:messageText];
        } completionHandler:^{
            [self.tableView reloadData];
        }];
    } else {
        UIAlertController * alertController = [self inviteContact:user.contact fromView:view];

        if (alertController) {
            [alertController presentInNotificationsWindow];
        }
    }
}

#pragma mark - ContactsViewControllerDelegate

- (void)contactsViewControllerDidCancel:(ContactsViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactsViewControllerDidNotShareContacts:(ContactsViewController *)controller
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [controller dismissViewControllerAnimated:true completion:nil];
    } else {
        [controller.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ContactsViewControllerContentDelegate

- (BOOL)contactsViewController:(ContactsViewController *)controller shouldDisplayActionButtonForUser:(ZMSearchUser *)user
{
    return YES;
}

- (NSArray *)actionButtonTitlesForContactsViewController:(ContactsViewController *)controller
{
    return @[
             NSLocalizedString(@"contacts_ui.action_button.open", @""),
             NSLocalizedString(@"contacts_ui.action_button.invite", @""),
             NSLocalizedString(@"connection_request.send_button_title", @""), // TODO: add separate string contacts_ui.action_button.connect
             ];
}

- (NSUInteger)contactsViewController:(ContactsViewController *)controller actionButtonTitleIndexForUser:(ZMSearchUser *)user
{
    if (user.isConnected || ((user.user.isPendingApprovalByOtherUser || user.user.isPendingApprovalBySelfUser) && ! user.user.isIgnored)) {
        return 0;
    } else if (user.user != nil && ! user.user.isIgnored && ! user.user.isPendingApprovalByOtherUser) {
        return 2;
    }
    else {
        return 1;
    }
}

- (void)contactsViewController:(ContactsViewController *)controller actionButton:(UIButton *)actionButton pressedForUser:(ZMSearchUser *)user
{
    [self inviteUser:user fromView:actionButton];
}

- (void)contactsViewController:(ContactsViewController *)controller didSelectCell:(ContactsCell *)cell forUser:(ZMSearchUser *)user
{
    [self inviteUser:user fromView:cell];
}

@end
