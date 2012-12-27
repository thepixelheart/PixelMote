//
//  PFConnectViewController.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/23/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFConnectViewController.h"
#import "PFConnectView.h"
#import "ELCTextfieldCell.h"
#import "PFGamepadViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "PFNetworkManager.h"

@interface PFConnectViewController ()

@end

@implementation PFConnectViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        CGRect frame = [UIScreen mainScreen].bounds;
        
        connectView = [[PFConnectView alloc] initWithFrame:frame];
        connectView.tableView.delegate = self;
        connectView.tableView.dataSource = self;
        connectView.delegate = self;
        [[self view] addSubview:connectView];
        
        labels = [NSArray arrayWithObjects:@"Host", @"Port", @"Alias", nil];
        
        images = [NSArray arrayWithObjects:@"host",@"port",@"alias", nil];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *credentials = [userDefaults objectForKey:@"credentials"];
        
        if (credentials) {
            defaults = [credentials copy];
        } else {
            defaults = @[@"192.168.0.", @"12345", @"scrottobaggins"];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ELCTextfieldCell *cell = (ELCTextfieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ELCTextfieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    //	cell.leftImage = [self.labels objectAtIndex:indexPath.row];
    
	cell.rightTextField.placeholder = [labels objectAtIndex:indexPath.row];
    cell.rightTextField.text = [defaults objectAtIndex:indexPath.row];
    cell.leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@icon.png", [images objectAtIndex:indexPath.row]]]];
    
	cell.indexPath = indexPath;
	cell.delegate = self;
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    if ([indexPath row] == labels.count - 1) {
        cell.rightTextField.returnKeyType = UIReturnKeyDone;
    } else {
        cell.rightTextField.returnKeyType = UIReturnKeyNext;
    }
}

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
	if(indexPath.row < [labels count]-1) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
		[[(ELCTextfieldCell*)[connectView.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
		[connectView.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
    
	else {
		ELCTextfieldCell *cell = (ELCTextfieldCell*)[connectView.tableView cellForRowAtIndexPath:indexPath];
        
        [[cell rightTextField] resignFirstResponder];        
	}
}

- (void)makeConnectionWithHost:(NSString *)host port:(NSInteger)port alias:(NSString *)a
{
    alias = [a copy];
    
    NSArray *credentials = @[host, [NSString stringWithFormat:@"%d", port], alias];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:credentials forKey:@"credentials"];
    [userDefaults synchronize];
    
    [[PFNetworkManager sharedInstance] initNetworkConnectionWithHost:host port:port block:^(BOOL success) {
        
        if (success) {
            [self sendConnectionMessage];
            
            PFGamepadViewController *gamepad = [[PFGamepadViewController alloc] initWithAlias:alias];
            [[self navigationController] pushViewController:gamepad animated:YES];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"An error occured. Please check the host and port" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (void)sendConnectionMessage
{
    if (alias) {
        NSString *message  = [NSString stringWithFormat:@"%@", alias];
        NSMutableData *data = [[NSMutableData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
        unsigned char nullTerminator[1] = {0};
        [data appendBytes:nullTerminator length:1];
        [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"h" data:data];
    }
}
@end
