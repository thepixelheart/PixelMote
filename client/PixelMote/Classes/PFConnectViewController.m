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

- (void)makeConnectionWithHost:(NSString *)host port:(NSString *)port alias:(NSString *)alias
{    
    NSString *uniqueId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    PFGamepadViewController *gamepad = [[PFGamepadViewController alloc] initWithUniqueId:uniqueId host:host port:[port intValue] alias:alias];
    [[self navigationController] pushViewController:gamepad animated:YES];
}
@end
