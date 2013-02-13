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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setEmitterPositionFromTouch: [touches anyObject]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setEmitterPositionFromTouch: [touches anyObject]];
    [fireView setIsEmitting:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setIsEmitting:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [fireView setIsEmitting:NO];
}


@end
