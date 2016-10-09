//
//  ConversationViewCell.h
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation;

@interface ConversationViewCell : UICollectionViewCell

@property (nonatomic, strong) Conversation *conversation;

@end
