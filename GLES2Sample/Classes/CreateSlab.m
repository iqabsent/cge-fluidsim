#include "Fluid.h"
//#include "Pez.h"



Slab CreateSlab(GLsizei width, GLsizei height, int numComponents)
{
    Slab slab;
    slab.Ping = CreateSurface(width, height, numComponents);
    slab.Pong = CreateSurface(width, height, numComponents);
    return slab;
}

Surface CreateSurface(GLsizei width, GLsizei height, int numComponents)
{
    GLuint fboHandle;
    glGenFramebuffers(1, &fboHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, fboHandle);

    GLuint textureHandle;
    glGenTextures(1, &textureHandle);
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    
    const int UseHalfFloats = 1;
    if (UseHalfFloats) {
        switch (numComponents) {
            case 1: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0); break;
            //case 1: glTexImage2D(GL_TEXTURE_2D, 0, 0x1908, width, height, 0, 0x1908, 0x140B, 0); break;
            case 2: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0); break;
            case 3: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,  GL_UNSIGNED_BYTE, 0); break;
            case 4: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0); break;
                //default: PezFatalError("Illegal slab format.");
        }
    } else {
        switch (numComponents) {
            case 1: glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width, height, 0, GL_RED_EXT, GL_FLOAT, 0); break;
            case 2: glTexImage2D(GL_TEXTURE_2D, 0, GL_RG32F_EXT, width, height, 0, GL_RG32F_EXT, GL_FLOAT, 0); break;
            case 3: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F_EXT, width, height, 0, GL_RGB32F_EXT, GL_FLOAT, 0); break;
            case 4: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_EXT, width, height, 0, GL_RGBA32F_EXT, GL_FLOAT, 0); break;
                //default: PezFatalError("Illegal slab format.");
        }
    }

    //PezCheckCondition(GL_NO_ERROR == glGetError(), "Unable to create normals texture");

    GLuint colorbuffer;
    glGenRenderbuffers(1, &colorbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorbuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureHandle, 0);
    //PezCheckCondition(GL_NO_ERROR == glGetError(), "Unable to attach color buffer");
    
    //PezCheckCondition(GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus(GL_FRAMEBUFFER), "Unable to create FBO.");
    Surface surface = { fboHandle, textureHandle, numComponents };

    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    return surface;
}
