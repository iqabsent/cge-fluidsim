//
//  DWFViewController.m
//  DrawWithFire
//
//  Created by Ray Wenderlich on 10/6/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "DWFViewController.h"

@implementation DWFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setMultipleTouchEnabled:YES];
    ActiveTouches = [[NSMutableArray alloc] init];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    for (UITouch *touch in touches) {
        [ActiveTouches replaceObjectAtIndex:[ActiveTouches indexOfObject:touch] withObject:touch ];
    }
    [fireView setEmitterPositionFromTouch: [ActiveTouches objectAtIndex:0]];
    if ([ActiveTouches count] > 1) { //two finger touch
        [fireView setEmitter2PositionFromTouch: [ActiveTouches objectAtIndex:1]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        if (![ActiveTouches containsObject:touch])
            [ActiveTouches addObject:touch];
    }
    [fireView setEmitterPositionFromTouch: [ActiveTouches objectAtIndex:0]];
    [fireView setIsEmitting:YES];
    
    if ([ActiveTouches count] > 1) { //two finger touch
        [fireView setEmitter2PositionFromTouch: [ActiveTouches objectAtIndex:1]];
        [fireView setIs2Emitting:YES];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [ActiveTouches removeObject:touch];
    }
    if([ActiveTouches count] < 2) [fireView setIs2Emitting:NO];
    if([ActiveTouches count] < 1)[fireView setIsEmitting:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setIsEmitting:NO];
    [fireView setIs2Emitting:NO];
}

@end
