//
//  User.m
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "User.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation User

- (instancetype)initWithPeerID:(MCPeerID *)peerID {
    self = [super init];
    
    if (self) {
        self.peerID = peerID;
        self.userName = peerID.displayName;
        self.profileImageName = nil;
    }
    
    return self;
}

@end
