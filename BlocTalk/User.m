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
        NSLog(@"peerID Description: %@", [peerID description]);
        self.uuid = [[NSUUID UUID] UUIDString];
        self.profileImageName = nil;
    }
    
    return self;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.peerID = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(peerID))];
        self.userName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userName))];
        self.uuid = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(uuid))];
        self.profileImageName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profileImageName))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.peerID forKey:NSStringFromSelector(@selector(peerID))];
    [aCoder encodeObject:self.userName forKey:NSStringFromSelector(@selector(userName))];
    [aCoder encodeObject:self.uuid forKey:NSStringFromSelector(@selector(uuid))];
    [aCoder encodeObject:self.profileImageName forKey:NSStringFromSelector(@selector(profileImageName))];
}



@end
