//
//  KSDemoViewController.m
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 30/12/2016.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSDemoViewController.h"
#import "KSPreviewViewController.h"
#import "YYWebImage.h"
#import "SDWebImageManager.h"

@interface KSDemoViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *dismissalSegementedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *backgroundSegementedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pageSegementedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *loadingSegementedControl;
@property (weak, nonatomic) IBOutlet UISwitch *bouncesSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *managerSegmentedControl;

@end

@implementation KSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    KSPreviewViewController *preview = [segue destinationViewController];
    preview.dismissalStyle = _dismissalSegementedControl.selectedSegmentIndex;
    preview.backgroundStyle = _backgroundSegementedControl.selectedSegmentIndex;
    preview.pageindicatorStyle = _pageSegementedControl.selectedSegmentIndex;
    preview.loadingStyle = _loadingSegementedControl.selectedSegmentIndex;
    preview.bounces = _bouncesSwitch.on;
    preview.imageManagerType = _managerSegmentedControl.selectedSegmentIndex;
}

// MARK: - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 7) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_managerSegmentedControl.selectedSegmentIndex == 0) {
            [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
            [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
        } else {
            [[SDWebImageManager sharedManager].imageCache clearMemory];
            [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:nil];
        }
    }
}

@end
