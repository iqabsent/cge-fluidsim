//
//  DWFParticleView.m
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

#import "DWFParticleView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DWFParticleView
{
    CAEmitterLayer* fireEmitter; //1
    CAEmitterLayer* fireEmitter2;
}

-(void)awakeFromNib
{
    //set ref to the layer
    fireEmitter = (CAEmitterLayer*)self.layer; //2
    //configure the emitter layer
    fireEmitter.emitterPosition = CGPointMake(50, 50);
    fireEmitter.emitterSize = CGSizeMake(10, 10);
    //set ref to the layer
    fireEmitter2 = (CAEmitterLayer*)self.layer; //2
    //configure the emitter layer
    fireEmitter2.emitterPosition = CGPointMake(50, 50);
    fireEmitter2.emitterSize = CGSizeMake(10, 10);
    
    
    CAEmitterCell* fire = [CAEmitterCell emitterCell];
    fire.birthRate = 0;
    fire.lifetime = 3.0;
    fire.lifetimeRange = 0.5;
    fire.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
    fire.contents = (id)[[UIImage imageNamed:@"Particles_fire.png"] CGImage];
    [fire setName:@"fire"];

    fire.velocity = 10;
    fire.velocityRange = 20;
    fire.emissionRange = M_PI_2;
    
    fire.scaleSpeed = 0.3;
    fire.spin = 0.5;

    fireEmitter.renderMode = kCAEmitterLayerAdditive;
    fireEmitter.emitterCells = [NSArray arrayWithObject:fire];

    fire.color = [[UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:0.1] CGColor];
    fireEmitter2.renderMode = kCAEmitterLayerAdditive;
    fireEmitter2.emitterCells = [NSArray arrayWithObject:fire];
    
    //add the cell to the layer and we're done
    
}

+ (Class) layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

-(void)setEmitterPositionFromTouch: (UITouch*)t
{
    //change the emitter's position
    fireEmitter.emitterPosition = [t locationInView:self];
}

-(void)setEmitter2PositionFromTouch: (UITouch*)t
{
    //change the emitter's position
    fireEmitter.emitterPosition = [t locationInView:self];
}

-(void)setIsEmitting:(BOOL)isEmitting
{
    //turn on/off the emitting of particles
    [fireEmitter setValue:[NSNumber numberWithInt:isEmitting?200:0] forKeyPath:@"emitterCells.fire.birthRate"];
}

-(void)setIs2Emitting:(BOOL)isEmitting
{
    //turn on/off the emitting of particles
    [fireEmitter2 setValue:[NSNumber numberWithInt:isEmitting?200:0] forKeyPath:@"emitterCells.fire.birthRate"];
}


@end
