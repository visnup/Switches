//
//  ViewController.m
//  Switches
//
//  Created by Visnu on 2/11/14.
//  Copyright (c) 2014 Visnu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *leftScreenEdgePanGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *rightScreenEdgePanGestureRecognizer;
- (IBAction)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.leftScreenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
  self.leftScreenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
  [self.view addGestureRecognizer:self.leftScreenEdgePanGestureRecognizer];

  self.rightScreenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
  self.rightScreenEdgePanGestureRecognizer.edges = UIRectEdgeRight;
  [self.view addGestureRecognizer:self.rightScreenEdgePanGestureRecognizer];

  [self becomeFirstResponder];

  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(defaultsDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
  [self defaultsDidChange];
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

- (IBAction)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    for (UIView *view in self.view.subviews)
      if ([view isKindOfClass:[UISwitch class]])
        [(UISwitch *)view setOn:(gestureRecognizer == self.leftScreenEdgePanGestureRecognizer) animated:YES];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (motion == UIEventSubtypeMotionShake)
    for (UIView *view in self.view.subviews)
      if ([view isKindOfClass:[UISwitch class]])
        [(UISwitch *)view setOn:arc4random_uniform(2) animated:YES];
}

- (void)defaultsDidChange
{
  BOOL rainbow = [[NSUserDefaults standardUserDefaults] boolForKey:@"rainbow"];
  [UIView animateWithDuration:0.2 animations:^{
    for (UIView *view in self.view.subviews)
      if ([view isKindOfClass:[UISwitch class]])
        [(UISwitch *)view setOnTintColor:rainbow ? [UIColor colorWithHue:arc4random_uniform(360)/360.0 saturation:0.65 brightness:0.84 alpha:1] : nil];

  }];
}

@end
