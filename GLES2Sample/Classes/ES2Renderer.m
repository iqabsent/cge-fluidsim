
#import "Fluid.h"
#import "ES2Renderer.h"
#import "Shaders.h"
#include "matrix.h"
static GLuint QuadVao;
static GLuint VisualizeProgram;
static Slab Velocity, Density, Pressure, Temperature;
static Surface Divergence, Obstacles, HiresObstacles;
// uniform index
enum {
	UNIFORM_MODELVIEW_PROJECTION_MATRIX,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

@interface ES2Renderer (PrivateMethods)
- (BOOL) loadShaders;
@end

@implementation ES2Renderer

// Create an ES 2.0 context
- (id <ESRenderer>) init
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
		{
            [self release];
            return nil;
        }
        
        int w = GridWidth;
        int h = GridHeight;
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffers(1, &defaultFramebuffer);
		glGenRenderbuffers(1, &colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        Velocity = CreateSlab(w, h, 2);
        Density = CreateSlab(w, h, 1);
        Pressure = CreateSlab(w, h, 1);
        Temperature = CreateSlab(w, h, 1);
        Divergence = CreateSurface(w, h, 3);
        InitSlabOps();
        VisualizeProgram = CreateProgram("Fluid.Vertex", 0, "Fluid.Visualize");
        
        Obstacles = CreateSurface(w, h, 3);
        CreateObstacles(Obstacles, w, h);
        
        w = ViewportWidth * 2;
        h = ViewportHeight * 2;
        HiresObstacles = CreateSurface(w, h, 1);
        CreateObstacles(HiresObstacles, w, h);
        
        QuadVao = CreateQuad();
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        ClearSurface(Temperature.Ping, AmbientTemperature);
        //PezUpdate(1600);
	}
	
	return self;
}


void PezUpdate(unsigned int elapsedMicroseconds)
{
    glViewport(0, 0, GridWidth*2, GridHeight*2);
    
    Advect(Velocity.Ping, Velocity.Ping, Obstacles, Velocity.Pong, VelocityDissipation);
    SwapSurfaces(&Velocity);
    
    Advect(Velocity.Ping, Temperature.Ping, Obstacles, Temperature.Pong, TemperatureDissipation);
    SwapSurfaces(&Temperature);
    
    Advect(Velocity.Ping, Density.Ping, Obstacles, Density.Pong, DensityDissipation);
    SwapSurfaces(&Density);
    
    ApplyBuoyancy(Velocity.Ping, Temperature.Ping, Density.Ping, Velocity.Pong);
    SwapSurfaces(&Velocity);
    
    ApplyImpulse(Temperature.Ping, ImpulsePosition, ImpulseTemperature);
    ApplyImpulse(Density.Ping, ImpulsePosition, ImpulseDensity);
    
    ComputeDivergence(Velocity.Ping, Obstacles, Divergence);
    ClearSurface(Pressure.Ping, 0);
    
    for (int i = 0; i < NumJacobiIterations; ++i) {
        Jacobi(Pressure.Ping, Divergence, Obstacles, Pressure.Pong);
        SwapSurfaces(&Pressure);
    }
    
    SubtractGradient(Velocity.Ping, Pressure.Ping, Obstacles, Velocity.Pong);
    SwapSurfaces(&Velocity);
}

//-(void) render:(GLuint)windowFbo
-(void) render

{
    
    [EAGLContext setCurrentContext:context];
    PezUpdate(1600);
    
    // Replace the implementation of this method to do your own custom drawing
    
    
    glBindFramebuffer(GL_FRAMEBUFFER,defaultFramebuffer);
    //glViewport(0,0,backingWidth,backingHeight) ;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(VisualizeProgram);
    GLint fillColor = glGetUniformLocation(VisualizeProgram, "FillColor");
    GLint scale = glGetUniformLocation(VisualizeProgram, "Scale");
    glEnable(GL_BLEND);

    //Draw Ink
	glBindTexture(GL_TEXTURE_2D, Density.Ping.TextureHandle);
    glUniform3f(fillColor, 1, 1, 1);
    glUniform2f(scale, 1.0f / ViewportWidth, 1.0f / ViewportHeight);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// Draw obstacles:
    glBindTexture(GL_TEXTURE_2D, HiresObstacles.TextureHandle);
    glUniform3f(fillColor, 0.125f, 0.4f, 0.75f);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	

    glDisable(GL_BLEND);
	
    
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}
- (BOOL)loadShaders {
    
    return YES;
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
	
    return YES;
}

- (void) dealloc
{
	// tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	// realease the shader program object
	if (program)
	{
		glDeleteProgram(program);
		program = 0;
	}
	
	// tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
