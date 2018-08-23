//
//  AspectsViewController.m
//  AspectsDemo
//
//  Created by Peter Steinberger on 05/05/14.
//  Copyright (c) 2014 PSPDFKit GmbH. All rights reserved.
//

#import "AspectsViewController.h"
#import "Aspects.h"
#import "AspectsInvocation.h"
@implementation AspectsViewController

- (IBAction)buttonPressed:(id)sender {
    UIViewController *testController = [[UIImagePickerController alloc] init];

//    AspectsInvocation *inDemo = [[AspectsInvocation alloc]init];
//    [inDemo test1];

    testController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:testController animated:YES completion:NULL];

    // We are interested in being notified when the controller is being dismissed.
    [testController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, BOOL animated) {
        NSLog(@"控制器消失");
    } error:NULL];

//    // Hooking dealloc is delicate, only AspectPositionBefore will work here.
//    [testController aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info) {
//        NSLog(@"Controller is about to be deallocated: %@", [info instance]);
//    } error:NULL];
//
    /*
     UIViewController *controller = [info instance];
     if (controller.isBeingDismissed || controller.isMovingFromParentViewController) {
     [[[UIAlertView alloc] initWithTitle:@"Popped" message:@"Hello from Aspects" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
     }
     */
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
@end
