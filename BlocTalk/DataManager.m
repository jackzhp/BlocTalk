//
//  ConversationManager.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "DataManager.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation DataManager {
    NSMutableArray *_conversations;
    NSMutableArray *_users;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        // abandoning the background threading for now..  would have to implement KVO or something to notify tableview to reload
//       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *fullUsersPath = [self pathForFilename:NSStringFromSelector(@selector(users))];
            NSArray *storedUsers = [NSKeyedUnarchiver unarchiveObjectWithFile:fullUsersPath];
            
            NSString *fullConversationsPath = [self pathForFilename:NSStringFromSelector(@selector(conversations))];
            NSArray *storedConversations = [NSKeyedUnarchiver unarchiveObjectWithFile:fullConversationsPath];

            
//        dispatch_async(dispatch_get_main_queue(), ^{
                if (storedUsers.count > 0) {
                    self.users = storedUsers;
                } else {
                    self.users = [NSMutableArray arrayWithCapacity:1];
                }
                if (storedConversations.count > 0) {
                    self.conversations = storedConversations;
                } else {
                    self.conversations = [NSMutableArray arrayWithCapacity:1];
                }
//            });
//        });
    }
    
    return self;
}

- (User *)userForPeerID:(MCPeerID *)peerID {
    for (User *user in self.users) {
        if([user.peerID isEqual:peerID]) {
            NSLog(@"user.peerID: %@ is equal to peerID: %@", user.peerID, peerID);
        }
        if ([user.peerID.displayName isEqualToString:peerID.displayName]) {
            return user;
        }
    }
    
    // user not found
    return nil;
}

- (Conversation *)conversationForPeerId:(MCPeerID *)peerID {
    for (Conversation *conversation in self.conversations) {
        if([conversation.user.peerID isEqual:peerID]) {
            NSLog(@"conversation.peerID: %@ is equal to peerID: %@", conversation.user.peerID, peerID);
        }
        if ([conversation.user.peerID.displayName isEqualToString:peerID.displayName]) {
            return conversation;
        }
    }
    
    // conversation not found
    return nil;
}

- (void)addConversation:(Conversation *)conversation {
    [_conversations addObject:conversation];
    [self saveData];
}

- (void)addUser:(User *)user {
    [_users addObject:user];
    [self saveData];
}

- (NSString *)pathForFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //    NSLog(@"paths: %@", paths);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    //    NSLog(@"dataPath: %@", dataPath);
    
    return dataPath;
}

- (void)saveData {
    if (self.users.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(users))];
            NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:self.users];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [usersData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write users file: %@", dataError);
            }
        });
    }
    
    if (self.conversations.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(conversations))];
            NSData *conversationsData = [NSKeyedArchiver archivedDataWithRootObject:self.conversations];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [conversationsData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write conversations file: %@", dataError);
            }
        });
    }
    
}

@end
