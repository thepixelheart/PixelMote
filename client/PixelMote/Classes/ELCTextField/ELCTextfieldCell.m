//
//  ELCTextfieldCell.m
//  MobileWorkforce
//
//  Created by Collin Ruffenach on 10/22/10.
//  Copyright 2010 ELC Tech. All rights reserved.
//

#import "ELCTextfieldCell.h"


@implementation ELCTextfieldCell

@synthesize delegate;
@synthesize leftImage;
@synthesize rightTextField;
@synthesize indexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
        leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_v2.png"]];
		[self addSubview:leftImage];
		
		rightTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        rightTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

        [rightTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [rightTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[rightTextField setDelegate:self];
		[rightTextField setPlaceholder:@"Right Field"];
		[rightTextField setFont:[UIFont systemFontOfSize:17]];
		[self addSubview:rightTextField];
    }
	
    return self;
}

//Layout our fields in case of a layoutchange (fix for iPad doing strange things with margins if width is > 400)
- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect origFrame = self.contentView.frame;
	if (leftImage != nil) {
		leftImage.frame = CGRectMake(origFrame.origin.x + 10.0f, origFrame.origin.y + 11.5f, 25, 25);
		rightTextField.frame = CGRectMake(origFrame.origin.x + 45, origFrame.origin.y, origFrame.size.width - 45, origFrame.size.height-1);
	} else {
		leftImage.hidden = YES;
		NSInteger imageWidth = 0;
		if (self.imageView.image != nil) {
			imageWidth = self.imageView.image.size.width + 5;
		}
		rightTextField.frame = CGRectMake(origFrame.origin.x+imageWidth+10, origFrame.origin.y, origFrame.size.width-imageWidth-20, origFrame.size.height-1);
	}
    rightTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

- (void)setLeftImage:(UIImageView *)l {
    [leftImage removeFromSuperview];
    leftImage = l;
    CGRect origFrame = self.contentView.frame;
    leftImage.frame = CGRectMake(origFrame.origin.x + 10.0f, origFrame.origin.y + 11.5f, 25, 25);
    [self addSubview:leftImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if([delegate respondsToSelector:@selector(textFieldDidReturnWithIndexPath:)]) {
		
		[delegate performSelector:@selector(textFieldDidReturnWithIndexPath:) withObject:indexPath];
	}
	
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	NSString *textString = self.rightTextField.text;
	
	if (range.length > 0) {
		
		textString = [textString stringByReplacingCharactersInRange:range withString:@""];
	} 
	
	else {
		
		if(range.location == [textString length]) {
			
			textString = [textString stringByAppendingString:string];
		}

		else {
			
			textString = [textString stringByReplacingCharactersInRange:range withString:string];	
		}
	}
	
	if([delegate respondsToSelector:@selector(updateTextLabelAtIndexPath:string:)]) {		
		[delegate performSelector:@selector(updateTextLabelAtIndexPath:string:) withObject:indexPath withObject:textString];
	}
	
	return YES;
}

- (void)dealloc {
	[rightTextField release];
	[indexPath release];
    [super dealloc];
}

@end
