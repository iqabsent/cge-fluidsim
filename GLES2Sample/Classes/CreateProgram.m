#include "Fluid.h"
#include "glsw.h"
#include <string.h>
//#include "Pez.h"
const char* PezResourcePath()
{
    return "demo";
}

GLuint CreateProgram(const char* vsKey, const char* gsKey, const char* fsKey)
{
    static int first = 1;
    if (first) {
        glswInit();
        glswAddPath("../", ".glsl");
        glswAddPath("./", ".glsl");

        char qualifiedPath[128];
        strcpy(qualifiedPath, PezResourcePath());
        strcat(qualifiedPath, "/");
        glswAddPath(qualifiedPath, ".glsl");
        glswAddDirective("*", "#version 100");

        first = 0;
    }
    
    const char* vsSource = glswGetShader(vsKey);
    //const char* gsSource = glswGetShader(gsKey);
    const char* fsSource = glswGetShader(fsKey);

    
    
    GLint compileSuccess;
    GLchar compilerSpew[256];
    GLuint programHandle = glCreateProgram();

    GLuint vsHandle = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vsHandle, 1, &vsSource, 0);
    glCompileShader(vsHandle);
    glGetShaderiv(vsHandle, GL_COMPILE_STATUS, &compileSuccess);
    glGetShaderInfoLog(vsHandle, sizeof(compilerSpew), 0, compilerSpew);
    NSLog(@"/output: %s", compilerSpew);
    //PezCheckCondition(compileSuccess, "Can't compile %s:\n%s", vsKey, compilerSpew);
    glAttachShader(programHandle, vsHandle);

//    GLuint gsHandle;
//    if (gsKey) {
//        gsHandle = glCreateShader(GL_GEOMETRY_SHADER);
//        glShaderSource(gsHandle, 1, &gsSource, 0);
//        glCompileShader(gsHandle);
//        glGetShaderiv(gsHandle, GL_COMPILE_STATUS, &compileSuccess);
//        glGetShaderInfoLog(gsHandle, sizeof(compilerSpew), 0, compilerSpew);
//        PezCheckCondition(compileSuccess, "Can't compile %s:\n%s", gsKey, compilerSpew);
//        glAttachShader(programHandle, gsHandle);
//    }
    
    GLuint fsHandle;
    if (fsKey) {
        fsHandle = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fsHandle, 1, &fsSource, 0);
        glCompileShader(fsHandle);
        glGetShaderiv(fsHandle, GL_COMPILE_STATUS, &compileSuccess);
        glGetShaderInfoLog(fsHandle, sizeof(compilerSpew), 0, compilerSpew);
        NSLog(@"/output: %s", compilerSpew);
        //PezCheckCondition(compileSuccess, "Can't compile %s:\n%s", fsKey, compilerSpew);
        glAttachShader(programHandle, fsHandle);
    }

    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    glGetProgramInfoLog(programHandle, sizeof(compilerSpew), 0, compilerSpew);
    NSLog(@"/Fragment Shader: %s", compilerSpew);

    return programHandle;
}
