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
#import "Conversation.h"
#import "MPCHandler.h"
#import "DataManager.h"
#import "ConnectedPeersTableViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import "ConversationDetailViewController.h"

@interface ConversationCollectionViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) NSMutableArray *connectedPeers;
@property (nonatomic, strong) User *user;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeftGestureRecognizer;

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
    
    int flag = 0;
    // Check to see if local user is in the data manager, otherwise create
    // TODO: try to find a better way to do this compare
    for (User *user in [DataManager sharedInstance].users) {
        if ([user.userName isEqualToString:[UIDevice currentDevice].name]) {
            self.user = user;
            flag = 1;
        }
    }
    
    // create a new local user that will persist across relaunch
    if (!flag) {
        self.user = [[User alloc] initWithPeerID:[MPCHandler sharedInstance].peerID andUUID:[[NSUUID UUID] UUIDString]];
        [[DataManager sharedInstance] addUser:self.user];
    }
    
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (IBAction)didSwipeLeft:(UISwipeGestureRecognizer *)sender {
    NSLog(@"did swipe left");
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint p = [sender locationInView: self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        if (indexPath != nil)
        {
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Archive"
                                         message:@"Archive Conversation?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           Conversation *conversation = [DataManager sharedInstance].conversations[indexPath.row];
                                           conversation.isArchived = YES;
                                           [[DataManager sharedInstance] saveData];
                                           [self.collectionView reloadData];
                                       }];
            UIAlertAction* cancelButton = [UIAlertAction
                                           actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {}];
            
            [alert addAction:okButton];
            [alert addAction:cancelButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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
//            [self sendNewMessage];
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
    
    if (self == self.navigationController.visibleViewController) {
        Conversation *conversation = notification.userInfo[@"conversation"];
        
        UIAlertController *alert = [conversation getAlertController];

        [self presentViewController:alert animated:YES completion:nil];
        [self.collectionView reloadData];
    }
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
        connectedPeersTblVC.user = self.user;
    }
    
    if ([segue.identifier isEqualToString:@"showConversationDetail"]) {
        ConversationDetailViewController *conversationDetailVC = [segue destinationViewController];
        conversationDetailVC.senderId = self.user.userName;
        conversationDetailVC.senderDisplayName = self.user.userName;
        ConversationViewCell *cell = (ConversationViewCell *)sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        Conversation *conversation =  [DataManager sharedInstance].conversations[path.row];
        conversationDetailVC.conversation = conversation;
    }

}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numOfSections = 0;
    if ([[DataManager sharedInstance] countOfUnarchivedConversations]) {
        numOfSections = 1;
        self.collectionView.backgroundView = nil;
    } else {
        UILabel *backgroundTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.collectionView.bounds.size.width - 150, self.collectionView.bounds.size.height)];
        backgroundTextLabel.numberOfLines = 0;
        backgroundTextLabel.text = @"No Active Conversations.  Hit + to select a Peer to start a conversation";
        backgroundTextLabel.textColor = [UIColor blackColor];
        backgroundTextLabel.textAlignment = NSTextAlignmentCenter;
        self.collectionView.backgroundView = backgroundTextLabel;
    }
    
    return numOfSections;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[DataManager sharedInstance] countOfUnarchivedConversations];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ConversationViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Conversation *conversation = [DataManager sharedInstance].conversations[indexPath.row];
    cell.conversation = conversation;
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
