////////////////////////////////////////////////////////////////////////////////
//
// (C) Andy Thomason 2011
//
// a game for Tom

#ifdef WIN32
  #define _CRT_SECURE_NO_WARNINGS 1
  // This is the "GL extension wrangler"
  // Note: you will need to use the right version of glew32s.lib (32 bit vs 64 bit)
  #define GLEW_STATIC
  #include "GL/glew.h"

  // This is the "GL utilities" framework for drawing with OpenGL
  #define FREEGLUT_STATIC
  #define FREEGLUT_LIB_PRAGMAS 0
  #include "GL/glut.h"
  #include "AL/al.h"
  #include "AL/alc.h"
#else
  #include "GLUT/glut.h"
  //#include "GL/glew.h"
  
#include "include/AL/alc.h"
#include "include/AL/al.h"

#endif

#include <list>
#include <stdio.h>
#include <math.h>
#include <assert.h>

#include "include/vector.h"
#include "include/matrix.h"
#include "include/shader.h"
#include "include/texture.h"

class box {
  vec4 center_;
  vec4 half_extents_;
public:
  void init(float cx, float cy, float hx, float hy) {
    // note that it is a convention for positions and colors
    // to have "1" in the w, distances to have "0" in the w.
    center_ = vec4(cx, cy, 0, 1);
    half_extents_ = vec4(hx, hy, 0, 0);
  }

  void draw(shader &shader, texture &tex) {
    // set the tetexure into slot 0
    tex.render(0);

    // set the uniforms
    shader.render();

    // set the attributes    
    float vertices[4*4] = {
      center_[0] - half_extents_[0], center_[1] - half_extents_[1], 0, 0,
      center_[0] + half_extents_[0], center_[1] - half_extents_[1], 1, 0,
      center_[0] + half_extents_[0], center_[1] + half_extents_[1], 1, 1,
      center_[0] - half_extents_[0], center_[1] + half_extents_[1], 0, 1,
    };

    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (void*)vertices );
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (void*)(vertices + 2) );
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(2);

    // kick the draw
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
  }
  
  void move(const vec4 &dir) {
    center_ += dir;
  }
  
  vec4 pos() const { return center_; }
  void set_pos(vec4 v) { center_ = v; }
  
  bool intersects(const box &rhs) {
    vec4 diff = (rhs.pos() - pos()).abs();
    vec4 min_distance = rhs.half_extents_ + half_extents_;
    return diff[0] < min_distance[0] && diff[1] < min_distance[1];
  }
};

class toms_game
{
  shader colour_shader_;
  GLint viewport_width_;
  GLint viewport_height_;
  enum { num_sources = 8 };
  enum { num_icons = 16 };
  ALuint sources[num_sources];
  ALuint buffers[256];
  unsigned cur_source;
  
  texture textures[40];
  box icons[num_icons];
  int icon_textures[num_icons];
  
  char keys[256];
  char prev_keys[256];
  
  void create_icon(int texture) {
    icons[0].init(0, 0, 1, 1);
    icon_textures[0] = texture;
  }
  
  void draw_world(shader &shader) {
    for (int i = 0; i != num_icons; ++i) {
      if (icon_textures[i] != -1) {
        icons[i].draw(shader, textures[icon_textures[i]]);
      }
    }
  }

  void simulate() {
    for (int i = 0; i != 256; ++i) {
      if (keys[i] && !prev_keys[i] && buffers[i]) {
        // choose one of eight sources in sequence
        ALuint source = sources[cur_source%num_sources];
        alSourcei(source, AL_BUFFER, buffers[i]);
        alSourcePlay(source);
        cur_source++;
        
        static const char keyboard[] =
          "  zxcvbnm "
          " asdfghjkl"
          " qwertyuio"
          "1234567890"
        ;
        for (int j=0; j != 40; ++j) {
          if (i == keyboard[j]) {
            create_icon(j);
            break;
          }
        }
      }
    }
    memcpy(prev_keys, keys, sizeof(prev_keys));
  }
  
  void render() {
    simulate();

    // clear the frame buffer and the depth
    glClearColor(0, 0, 1, 1);
    glViewport(0, 0, viewport_width_, viewport_height_);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    draw_world(colour_shader_);

    // swap buffers so that the image is displayed.
    // gets a new buffer to draw a new scene.
    glutSwapBuffers();
  }


  void create_audio_resources() {    
    ALCdevice *dev = alcOpenDevice(NULL);
    assert(dev);
    ALCcontext *ctx = alcCreateContext(dev, NULL);
    alcMakeContextCurrent(ctx);
    assert(ctx);
    
    alGenSources(num_sources, sources);
    alGenBuffers(256, buffers);
    
    size_t magic_offset = 44;
    FILE *file = fopen("/Users/pergriffiths/opengl_es_2.0/iPhone/andy_tomsgame/assets/abc.wav", "rb");
    assert(file && "assets/abc.wav not found");
    fseek(file, 0, SEEK_END);
    size_t length = ftell(file);
    fseek(file, 0, SEEK_SET);
    char *tmp = (char*)malloc(length);
    fread(tmp, 1, length, file);
    fclose(file);
    //for( int i = 0; i != 44; ++i) printf("%02x ", tmp[i]&0xff);
    
    // use the labels file to build the buffers for the sound
    FILE *labels = fopen("/Users/pergriffiths/opengl_es_2.0/iPhone/andy_tomsgame/assets/abc_labels.txt","r");
    assert(labels && "assets/abc_labels.txt not found");
    char line[64];
    while (fgets(line, sizeof(line), labels)) {
      float start, end;
      char name[64];
      sscanf(line, "%f %f %s", &start, &end, name);
      size_t start_offset = magic_offset + 2* (int)(44100*start);
      size_t end_offset = magic_offset + 2 * (int)(44100*end);

      //printf("%d %d %d %s [%d]\n", buffer_idx, start_offset, end_offset, name, length);
      assert(start_offset < length && end_offset > start_offset && end_offset < length);

      alBufferData(
        buffers[name[0]],
        AL_FORMAT_MONO16,
        tmp + start_offset,
        end_offset - start_offset,
        44100
      );
    }
    fclose(labels);
    free(tmp);
    
    alListener3f(AL_POSITION, 0, 0, 0);
    cur_source = 0;
    
    for (int i = 0; i != num_icons; ++i) {
      icon_textures[i] = -1;
    }
    create_icon(0);
  }

  void create_texture_resources() {
    FILE *file = fopen("/Users/pergriffiths/opengl_es_2.0/iPhone/andy_tomsgame/assets/keyboard.tga", "rb");
    assert(file && "assets/keyboard.tga not found");
    fseek(file, 0, SEEK_END);
    size_t length = ftell(file);
    fseek(file, 0, SEEK_SET);
    char *tmp = (char*)malloc(length);
    fread(tmp, 1, length, file);
    
    int tex_idx = 0;
    for (int y = 0; y != 1024; y += 256) {
      for (int x = 0; x != 2560; x += 256) {
        textures[tex_idx++].init(tmp, x, y, 256, 256);
      }
    }
    
    fclose(file);
    free(tmp);
  }
  
  toms_game()
  {
    memset(keys, 0, sizeof(keys));
    memset(prev_keys, 0, sizeof(prev_keys));
    
    // set up a simple shader to render the emissve color
    colour_shader_.init(
      // just copy the position attribute to gl_Position
      "varying vec2 uv_;"
      "attribute vec4 pos;"
      "attribute vec2 uv;"
      "void main() { gl_Position = pos; uv_ = uv; }",

      // just copy the color attribute to gl_FragColor
      "varying vec2 uv_;"
      "uniform sampler2D texture;"
      "void main() { gl_FragColor = texture2D(texture, uv_); }"
    );
    
    create_audio_resources();
    
    create_texture_resources();
  }
  
  // The viewport defines the drawing area in the window
  void set_viewport(int w, int h) {
    viewport_width_ = w;
    viewport_height_ = h;
  }
  
  void set_key(int key, int value) {
    keys[key & 0xff] = value;
  }
public:
  // a singleton: one instance of this class only!
  static toms_game &get()
  {
    static toms_game singleton;
    return singleton;
  }

  // interface from GLUT
  static void reshape(int w, int h) { get().set_viewport(w, h); }
  static void display() { get().render(); }
  static void timer(int value) { glutTimerFunc(30, timer, 1); glutPostRedisplay(); }
  static void key_down( unsigned char key, int x, int y) { get().set_key(key, 1); }
  static void key_up( unsigned char key, int x, int y) { get().set_key(key, 0); }
};

// boilerplate to run the sample
int main(int argc, char **argv)
{
  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGBA|GLUT_DEPTH|GLUT_DOUBLE);
  glutInitWindowSize(1000, 1000);
  glutCreateWindow("tom's game");
//  glewInit();
//  if (!glewIsSupported("GL_VERSION_2_0") )
//  {
//    printf("OpenGL 2 is required!\n");
//    return 1;
//  }
  glutDisplayFunc(toms_game::display);
  glutReshapeFunc(toms_game::reshape);
  glutKeyboardFunc(toms_game::key_down);
  glutKeyboardUpFunc(toms_game::key_up);
  glutTimerFunc(30, toms_game::timer, 1);
  glutMainLoop();
  return 0;
}

