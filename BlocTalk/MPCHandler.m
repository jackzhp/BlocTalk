//
//  MPCHandler.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "MPCHandler.h"
#import "User.h"

@implementation MPCHandler 

#pragma mark - Init and setup

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.peerID = nil;
        self.session = nil;
        self.browser = nil;
        self.advertiser = nil;
        self.activePeers = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

- (void)setupPeerAndSessionWithDisplayName:(NSString *)displayName {
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:@"talk"];
    self.advertiser.delegate = self;
    [self.advertiser startAdvertisingPeer];
    NSLog(@"Advertising for peers...");
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"talk"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
    NSLog(@"Browsing for peers...");
}

#pragma mark - Message Sending

- (BOOL)sendMessage:(NSString*)message {
    
    NSData *dataToSend = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    [self.session sendData:dataToSend
                   toPeers:[self.session connectedPeers]
                  withMode:MCSessionSendDataReliable
                     error:&error];
    
    if (error) {
        NSLog(@"Send Error:%@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


#pragma mark - MCSession Delegate methods

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state": [NSNumber numberWithInt:state]
                           };
    
    NSLog(@"peerID: %@ DidChangeState to state: %ld", peerID, (long)state);
    
    // need to dispatch to main thread?
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MPCHandlerDidChangeStateNotification"
                                                            object:nil
                                                          userInfo:dict];
    });
   
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID,
                           @"textData": [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding]
                           };
    
    // Save data
//    NSString *conversation = self.historyByPeer[peerID.displayName];
//    if (conversation == nil) {
//        self.historyByPeer[peerID.displayName] = @"";
//        conversation = self.historyByPeer[peerID.displayName];
//    }
//    conversation = [conversation stringByAppendingFormat:@"%@> %@\n",peerID.displayName,dict[@"textData"]];
//    self.historyByPeer[peerID.displayName] = conversation;
    
    // need to dispatch to main thread?
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MPCHandlerDidReceiveDataNotification"
                                                            object:nil
                                                          userInfo:dict];
        
    });
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
    
    certificateHandler(YES);
}

#pragma mark - MCNearbyServiceBrowserDelegate Methods

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"Found peer with ID: %@", peerID);
    [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0];
    User *user = [[User alloc] init];
    user.peerID = peerID;
    user.userName = peerID.displayName;
    
    [self.activePeers addObject:user];
    
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer with ID: %@", peerID.displayName);
    
    NSUInteger index = NSIntegerMax;
    for (User *user in self.activePeers) {
        if (user.peerID == peerID) {
            index = [self.activePeers indexOfObject:user];
        }
    }
   
    if (!(index == NSIntegerMax)) {
        NSLog(@"Removing %@ from activePeers array", self.activePeers[index]);
        [self.activePeers removeObjectAtIndex:index];
    } else {
        NSLog(@"Error: couldn't find peer in activePeers array");
    }
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
    // worked a lot better once I removed these two lines, seems like I should use the session that was already created (self.session)?
    
//    self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
//    self.session.delegate = self;
    
    NSLog(@"Accepting invitation from %@", peerID.displayName);
    invitationHandler(YES, self.session);
}

@end
