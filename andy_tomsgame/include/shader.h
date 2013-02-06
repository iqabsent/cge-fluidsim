class shader {
  GLuint program_;
  GLuint textureIndex_;
public:
  shader() {}
  
  void init(const char *vs, const char *fs) {
    bool debug = true;
    GLsizei length;
    GLchar buf[256];

    // create our vertex shader and compile it
    GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex_shader, 1, &vs, NULL);
    glCompileShader(vertex_shader);
    glGetShaderInfoLog(vertex_shader, sizeof(buf), &length, buf);
    puts(buf);
    
    // create our fragment shader and compile it
    GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment_shader, 1, &fs, NULL);
    glCompileShader(fragment_shader);
    glGetShaderInfoLog(fragment_shader, sizeof(buf), &length, buf);
    puts(buf);

    // assemble the program for use by glUseProgram
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    
    // pos and normal are always 0 and 1
    glBindAttribLocation(program, 0, "pos");
    glBindAttribLocation(program, 2, "uv");
    glLinkProgram(program);
    program_ = program;
    glGetProgramInfoLog(program, sizeof(buf), &length, buf);
    puts(buf);
    
    textureIndex_ = glGetUniformLocation(program, "texture");
    if( debug ) printf("textureIndex_=%d\n", textureIndex_);
  }
  
  // set the uniforms
  void render() {
    glUseProgram(program_);

    // texture unit 0
    glUniform1i(textureIndex_, 0);
  }
};
