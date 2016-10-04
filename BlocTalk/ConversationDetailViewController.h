//
//  ConversationDetailViewController.h
//  BlocTalk
//
//  Created by Jonathan on 10/2/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

@class Conversation;

@interface ConversationDetailViewController : JSQMessagesViewController

@property (nonatomic, assign) NSInteger selectedCellRow;
@property (nonatomic, strong) Conversation *conversation;

@end
