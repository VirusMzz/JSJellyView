//
//  ViewController.m
//  JSJellyView
//
//  Created by V on 11/4/2016.
//  Copyright © 2016 V. All rights reserved.
//

#import "ViewController.h"
#import "JSJellyView.h"


@interface ViewController ()

@property (nonatomic, strong)JSJellyView *jellyView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.jellyView = [[JSJellyView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 350)];
    self.jellyView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.jellyView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
