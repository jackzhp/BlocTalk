//
//  ConversationCollectionViewController.m
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "ConversationCollectionViewController.h"
#import "ConversationViewCell.h"
#import "User.h"
#import "Message.h"
#import "Conversation.h"
#import "MPCHandler.h"
#import "DataManager.h"
#import "ConnectedPeersTableViewController.h"

@interface ConversationCollectionViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) NSMutableArray *connectedPeers;

@end

@implementation ConversationCollectionViewController

static NSString * const reuseIdentifier = @"ConversationViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftBarButtonItem.title = @"\u2699\uFE0E";
    
    // Initialize Multipeer connectivity handler
    [[MPCHandler sharedInstance] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    
    // Initialize Conversation Manager
    [DataManager sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MPCHandlerDidChangeStateNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNewData:)
                                                 name:@"MPCHandlerDidReceiveDataNotification"
                                               object:nil];
    

    
    self.connectedPeers = [NSMutableArray arrayWithCapacity:1];
    
}

- (void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    NSLog(@"peer %@:%@ (%ld)",peerID,peerDisplayName,(long)state);
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            NSLog(@"Peer connected!");
            [self.connectedPeers addObject:peerDisplayName];
            [self sendNewMessage];
            //TODO: show alert to user with connnected peer's name?
        }
        else if (state == MCSessionStateNotConnected){
            if ([self.connectedPeers count] > 0) {
                NSLog(@"Peer NOT connected!");
                NSUInteger indexOfPeer = [self.connectedPeers indexOfObject: peerDisplayName];
                [self.connectedPeers removeObjectAtIndex:indexOfPeer];
            }
        }
        
        [self.collectionView reloadData];
    }
}

- (void)sendNewMessage {
    [[MPCHandler sharedInstance] sendMessage:@"some test text"];
}

- (void)processNewData:(NSNotification *)notification {
    // create conversation object
    
    //add
    
    //reload
    
//    [[DataManager sharedInstance] addConversationWithDictionary:notification.userInfo andCompletionHandler:^(NSError *error) {
//        if (error == nil) {
//            [self.collectionView reloadData];
//        } else {
//            NSLog(@"%@",error.description);
//        }
//    }];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showConnectedPeersSegue"]) {
        ConnectedPeersTableViewController *connectedPeersTblVC = [segue destinationViewController];
        connectedPeersTblVC.connectedPeers = self.connectedPeers;
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [DataManager sharedInstance].conversations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ConversationViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSString *userLabel = [[DataManager sharedInstance].conversations[indexPath.row] user];
    NSArray *messages = [[DataManager sharedInstance].conversations[indexPath.row] messages];
    // get the last object (latest message) to show on conversations screen
    Message *message = [messages lastObject];
    NSString *messageText = message.text;
    
    cell.userNameLabel.text = userLabel;
    cell.conversationTextView.text = messageText;
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
