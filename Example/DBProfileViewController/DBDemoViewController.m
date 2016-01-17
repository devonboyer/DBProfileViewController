//
//  DBDemoViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-16.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBDemoViewController.h"
#import "DBUserProfileViewController.h"

@interface DBDemoViewController ()

@end

@implementation DBDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showUserProfile1"]) {
        DBUserProfileViewController *viewController = [segue destinationViewController];
        viewController.style = DBUserProfileViewControllerStyle1;
    } else if ([segue.identifier isEqualToString:@"showUserProfile2"]) {
        DBUserProfileViewController *viewController = [segue destinationViewController];
        viewController.style = DBUserProfileViewControllerStyle2;
    }
}


@end
