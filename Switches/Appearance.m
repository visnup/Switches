//
//  Appearance.m
//  Switches
//
//  Created by Visnu on 2/15/14.
//  Copyright (c) 2014 Visnu. All rights reserved.
//

#import "Appearance.h"

@implementation Appearance

+ (UIFont *)sansSerif
{
  return [self sansSerif:[UIFont labelFontSize]];
}

+ (UIFont *)sansSerif:(CGFloat)size
{
  return [UIFont fontWithName:@"Arial Rounded MT Bold" size:size];
}

+ (void)apply
{
//  NSLog(@"fonts=%@", [[UIFont familyNames] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]);
  [[UILabel appearance] setFont:[self sansSerif]];
  [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[self sansSerif:15.0]];

  [[UITextField appearance] setFont:[self sansSerif]];
  [[UITextView appearance] setFont:[self sansSerif]];

  [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [self sansSerif]}];
  [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [self sansSerif]} forState:UIControlStateNormal];
}

@end
