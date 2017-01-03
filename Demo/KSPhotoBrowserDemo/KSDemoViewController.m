//
//  KSDemoViewController.m
//  AVPlayerDemo
//
//  Created by Kyle Sun on 30/12/2016.
//  Copyright © 2016 skx926. All rights reserved.
//

#import "KSDemoViewController.h"
#import "KSPreviewViewController.h"

@interface KSDemoViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *dismissalSegementedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *backgroundSegementedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pageSegementedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *loadingSegementedControl;
@property (weak, nonatomic) IBOutlet UISwitch *bouncesSwitch;

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
}

@end
