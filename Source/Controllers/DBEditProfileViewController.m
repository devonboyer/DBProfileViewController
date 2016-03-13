//
//  DBEditProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-12.
//
//

#import "DBEditProfileViewController.h"
#import "DBEditProfileContentController.h"
#import "DBProfileDetailsView.h"

@interface DBEditProfileViewController ()

@property (nonatomic, strong) DBEditProfileContentController *editProfileContentController;

@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *doneBarButtonItem;

@end

@implementation DBEditProfileViewController

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.editProfileContentController = [[DBEditProfileContentController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Edit Profile";
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    
    self.delegate = self;
    self.dataSource = self;
    
    self.coverPhotoMimicsNavigationBar = NO;
        
    [self setProfilePicture:[UIImage imageNamed:@"demo-profile-picture"] animated:NO];
    [self setCoverPhoto:[UIImage imageNamed:@"demo-cover-photo-2"] animated:NO];
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.editProfileButton.hidden = YES;
    detailsView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
}

#pragma mark - Overrides

- (DBProfilePictureSize)profilePictureSize {
    return DBProfilePictureSizeEditProfile;
}

- (BOOL)allowsPullToRefresh {
    return NO;
}

#pragma mark - Action Responders

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DBProfileViewControllerDataSource

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController {
    return 1;
}

- (DBProfileContentController *)profileViewController:(DBProfileViewController *)profileViewController contentControllerAtIndex:(NSUInteger)index {
    return self.editProfileContentController;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)index {
    return @"Edit Profile";
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)index {
    return @"";
}

#pragma mark - DBProfileViewControllerDelegate

@end
