//
//  MPCHandler.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "MPCHandler.h"
#import "DataManager.h"
#import "User.h"
#import "Conversation.h"
#import <JSQMessages.h>

static NSString * const kDisplayNameKey = @"CurrentUserDisplayName";
static NSString * const kPeerIDKey = @"CurrentUserPeerID";

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
    // save PeerID to disk and reload to keep consistent across app launches
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldDisplayName = [defaults stringForKey:kDisplayNameKey];
    
    if ([oldDisplayName isEqualToString:displayName]) {
        NSData *peerIDData = [defaults dataForKey:kPeerIDKey];
        self.peerID = [NSKeyedUnarchiver unarchiveObjectWithData:peerIDData];
    } else {
        self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        NSData *peerIDData = [NSKeyedArchiver archivedDataWithRootObject:self.peerID];
        [defaults setObject:peerIDData forKey:kPeerIDKey];
        [defaults setObject:displayName forKey:kDisplayNameKey];
        [defaults synchronize];
    }
    
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
    
    //TODO: send to all peers or just to who the conversation is with?
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
    // get user for peerID
    User *user = [[DataManager sharedInstance] userForPeerID:peerID];
    NSString *messageText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDate *timestamp = [NSDate date];
    NSDictionary *dict;
    
    if (user) {
        // create new message
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.uuid senderDisplayName:user.userName date:timestamp text:messageText];
        
        //check what conversation it belongs to
        // change this method to conversationForUser:?
        Conversation *conversation = [[DataManager sharedInstance] conversationForPeerId:peerID];
        
        //if not, create a new one and add it to the data manager array
        if (!conversation) {
            conversation = [[Conversation alloc] initWithUser:user];
            [[DataManager sharedInstance] addConversation:conversation];
        }
        
        // if conversation is archived, unarchive it
        if (conversation.isArchived) {
            conversation.isArchived = NO;
        }
        
        //attach to conversation
        [conversation addMessage:message];
        //send conversation in notification
        dict = @{@"conversation": conversation};
       
    } else {
        // maybe send some error data?
        dict = nil;
    }
    
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
    
    
    // Should only invite on one side of the connection, this compares peerID display names and only sends an invite to the peer with the higher lexical ordering
    BOOL shouldInvite = ([self.peerID.displayName compare:peerID.displayName] == NSOrderedDescending);
    
    if (shouldInvite) {
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:10.0];
    } else {
        NSLog(@"Not inviting");
    }
    
    User *user = [[DataManager sharedInstance] userForPeerID:peerID];
    // check to see if this user has connected before?
    if (!user) {
        user = [[User alloc] initWithPeerID:peerID andUUID:[[NSUUID UUID] UUIDString]];
        [[DataManager sharedInstance] addUser:user];
    }
    
    if (![self.activePeers containsObject:user]) {
        [self.activePeers addObject:user];
    }
    
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer with ID: %@", peerID.displayName);
    
    NSUInteger index = NSIntegerMax;
    for (User *user in self.activePeers) {
        if ([user.peerID isEqual:peerID]) {
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
