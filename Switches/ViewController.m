//
//  ViewController.m
//  Switches
//
//  Created by Visnu on 2/11/14.
//  Copyright (c) 2014 Visnu. All rights reserved.
//

#import "ViewController.h"

typedef NS_ENUM(NSInteger, MessageType) {
  MessageTypeSetup,
  MessageTypeValueChanged
};

static NSArray *COLORS = nil;


@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
  NSUInteger count = [self count];
  for (NSUInteger i = 0; i < count; i++) {
    // Select a random element between i and end of array to swap with.
    NSUInteger r = arc4random_uniform((u_int32_t)(count - i)) + i;
    [self exchangeObjectAtIndex:i withObjectAtIndex:r];
  }
}

@end

@interface ViewController ()

@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiser;
@property (strong, nonatomic) NSArray *switches;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  COLORS = @[ [UIColor colorWithHue:0.3611111111 saturation:0.61 brightness:0.84 alpha:1],
              [UIColor colorWithHue:0 saturation:0.61 brightness:0.84 alpha:1] ];

  MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
  self.session = [[MCSession alloc] initWithPeer:peerID
                                securityIdentity:nil
                            encryptionPreference:MCEncryptionNone];
  self.session.delegate = self;

  self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"visnup-switches"
                                                         discoveryInfo:nil
                                                               session:self.session];
  [self.advertiser start];

  NSMutableArray *switches = [NSMutableArray new];
  for (UIView *view in self.view.subviews) {
    if ([view isKindOfClass:[UISwitch class]]) {
      UISwitch *sw = (UISwitch *)view;
      [sw addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
      [sw setOn:NO];
      [sw setTag:switches.count];
      switches[switches.count] = view;
    }
  }

  self.switches = switches;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.destinationViewController isKindOfClass:[MCBrowserViewController class]]) {
    MCBrowserViewController *browser = [segue.destinationViewController initWithServiceType:@"visnup-switches" session:self.session];
    browser.delegate = self;
  }
}

- (void)valueChanged:(UISwitch *)sender
{
  if (self.session.connectedPeers.count) {
    NSDictionary *message = @{ @"type": [NSNumber numberWithInteger:MessageTypeValueChanged],
                               @"tag": [NSNumber numberWithInteger:sender.tag],
                               @"on": [NSNumber numberWithBool:sender.on] };
    NSError *error;
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:message]
                   toPeers:self.session.connectedPeers
                  withMode:MCSessionSendDataReliable
                     error:&error];
    NSAssert(!error, @"error=%@", error);
  }

  [self updateScore];
}

- (BOOL)isLeader
{
  MCPeerID *leader = [[self.session.connectedPeers sortedArrayUsingSelector:@selector(displayName)] firstObject];
  return [[leader displayName] compare:[self.session.myPeerID displayName]] == NSOrderedAscending;
}

- (void)updateScore
{
  NSUInteger one = 0, two = 0;
  for (UISwitch *view in self.switches) {
    if (view.on) {
      if ([view.onTintColor isEqual:COLORS[0]])
        one++;
      else
        two++;
    }
  }

  self.navigationItem.title = [NSString stringWithFormat:@"%lu – %lu", one, two];
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
  [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
  [browserViewController dismissViewControllerAnimated:YES completion:nil];
  if ([self isLeader]) {
    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:self.switches.count];
    for (NSUInteger i = 0; i < self.switches.count; i++)
      colors[i] = [NSNumber numberWithUnsignedInteger:i % COLORS.count];
    [colors shuffle];

		for (NSUInteger i = 0; i < self.switches.count; i++)
      [self.switches[i] setOnTintColor:COLORS[[colors[i] unsignedIntegerValue]]];

    NSMutableArray *teams = [[NSMutableArray alloc] initWithCapacity:2];

    NSDictionary *message = @{ @"type": [NSNumber numberWithInteger:MessageTypeSetup],
                               @"colors": colors,
                               @"teams": teams };
    NSError *error;
    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:message]
                   toPeers:self.session.connectedPeers
                  withMode:MCSessionSendDataReliable
                     error:&error];
    NSAssert(!error, @"error=%@", error);
  }
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  if (state == MCSessionStateNotConnected)
    [self performSegueWithIdentifier:@"presentBrowser" sender:self];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  NSDictionary *message = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
  switch ([message[@"type"] integerValue]) {
    case MessageTypeSetup: {
      NSArray *colors = message[@"colors"];
      dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i = 0; i < self.switches.count; i++) {
          [self.switches[i] setOnTintColor:COLORS[[colors[i] unsignedIntegerValue]]];
          [self.switches[i] setOn:NO];
        }
      });
      break;
    }
    case MessageTypeValueChanged:
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.switches[[message[@"tag"] longValue]] setOn:[message[@"on"] boolValue] animated:YES];
        [self updateScore];
      });
      break;
  }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

@end
