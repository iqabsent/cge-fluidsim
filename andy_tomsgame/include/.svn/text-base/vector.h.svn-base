class mat4;

#if defined( USE_SSE )
class vec4 {
  static const char *Copyright() { return "Copyright(C) Andy Thomason 2011"; }
  __m128 v128;
public:
  vec4() {}
  vec4(__m128 value) { v128 = value; }
  vec4(float x, float y, float z, float w) { v128 = _mm_setr_ps(x, y, z, w); };
  float &operator[](int i) { return v128.m128_f32[i]; }
  const float &operator[](int i) const { return v128.m128_f32[i]; }
  vec4 operator*(float r) const { return vec4(_mm_mul_ps(v128, _mm_set_ss(r))); }
  vec4 operator*(const mat4 &r) const;
  vec4 operator+(const vec4 &r) const { return vec4(_mm_add_ps(v128, r.v128)); }
  vec4 operator-(const vec4 &r) const { return vec4(_mm_sub_ps(v128, r.v128)); }
  vec4 operator*(const vec4 &r) const { return vec4(_mm_mul_ps(v128, r.v128)); }
  vec4 operator-() const { return vec4(_mm_sub_ps(_mm_setzero_ps(), v128)); }
  vec4 &operator+=(const vec4 &r) { v128 = _mm_add_ps(v128, r.v128); return *this; }
  vec4 &operator-=(const vec4 &r) { v128 = _mm_sub_ps(v128, r.v128); return *this; }
  vec4 qconj() const { __m128 n = { -1, -1, -1, 1 }; return vec4(_mm_mul_ps(v128, n)); }
  float dot(const vec4 &r) const { __m128 p = _mm_mul_ps(v128, r.v128); p = _mm_add_ps(p,_mm_shuffle_ps(p, _MM_SHUFFLE(2,3,0,1))); p = _mm_add_ps(p,_mm_shuffle_ps(p, _MM_SHUFFLE(0,2,0,2))); return p.m128_f32[0]; }
  vec4 perspectiveDivide() const { float r = 1.0f / v128.m128_f32[3]; return *this * r; }
  vec4 normalise() { return *this * lengthRecip(); }
  float length() { return sqrtf(dot(*this)); }
  float lengthRecip() { return 1.0f/sqrtf(dot(*this)); }
  float lengthSquared() { return dot(*this); }
  vec4 abs() const { return vec4(fabsf(v[0]), fabsf(v[1]), fabsf(v[2]), fabsf(v[3])); }
  bool operator <(const vec4 &r) { return v[0] < r.v[0] && v[1] < r.v[1] && v[2] < r.v[2] && v[3] < r.v[3]; }
  bool operator <=(const vec4 &r) { return v[0] <= r.v[0] && v[1] <= r.v[1] && v[2] <= r.v[2] && v[3] <= r.v[3]; }
  vec4 xyz() const { return vec4(v[0], v[1], v[2], 0); }
  vec4 qmul(const vec4 &r) const {
    return vec4(
	    v[0] * r.v[3] + v[3] * r.v[0] + v[1] * r.v[2] - v[2] * r.v[1],
		  v[1] * r.v[3] + v[3] * r.v[1] + v[2] * r.v[0] - v[0] * r.v[2],
		  v[2] * r.v[3] + v[3] * r.v[2] + v[0] * r.v[1] - v[1] * r.v[0],
		  v[3] * r.v[3] - v[0] * r.v[0] - v[1] * r.v[1] - v[2] * r.v[2]
    );
  }
  vec4 cross(const vec4 &r) const {
    return vec4(
      v[1] * r.v[2] - v[2] * r.v[1],
	    v[2] * r.v[0] - v[0] * r.v[2],
	    v[0] * r.v[1] - v[1] * r.v[0],
	    0
	  );
  }

  float *get() { return &v[0]; }

  const float *get() const { return &v[0]; }

  /*void dump() const {
    printf("{%.3f, %.3f, %.3f, %.3f}\n", v[0], v[1], v[2], v[3]);
  }*/

  const char *toString() const
  {
    static char buf[4][32];
    static int i = 0;
    char *dest = buf[i++&3];
    sprintf(dest, "{%.3f, %.3f, %.3f, %.3f}", v[0], v[1], v[2], v[3]);
    return dest;
  }
};

#else

class vec4 {
  static const char *Copyright() { return "Copyright(C) Andy Thomason 2011"; }
  float v[4];
public:
  vec4() {}
  vec4(float x, float y, float z, float w) { v[0] = x; v[1] = y; v[2] = z; v[3] = w; };
  float &operator[](int i) { return v[i]; }
  const float &operator[](int i) const { return v[i]; }
  vec4 operator*(float r) const { return vec4(v[0]*r, v[1]*r, v[2]*r, v[3]*r); }
  vec4 operator*(const mat4 &r) const;
  vec4 operator+(const vec4 &r) const { return vec4(v[0]+r.v[0], v[1]+r.v[1], v[2]+r.v[2], v[3]+r.v[3]); }
  vec4 operator-(const vec4 &r) const { return vec4(v[0]-r.v[0], v[1]-r.v[1], v[2]-r.v[2], v[3]-r.v[3]); }
  vec4 operator*(const vec4 &r) const { return vec4(v[0]*r.v[0], v[1]*r.v[1], v[2]*r.v[2], v[3]*r.v[3]); }
  vec4 operator-() const { return vec4(-v[0], -v[1], -v[2], -v[3]); }
  vec4 &operator+=(const vec4 &r) { v[0] += r.v[0]; v[1] += r.v[1]; v[2] += r.v[2]; v[3] += r.v[3]; return *this; }
  vec4 &operator-=(const vec4 &r) { v[0] -= r.v[0]; v[1] -= r.v[1]; v[2] -= r.v[2]; v[3] -= r.v[3]; return *this; }
  vec4 qconj() const { return vec4(-v[0], -v[1], -v[2], v[3]); }
  float dot(const vec4 &r) const { return v[0] * r.v[0] + v[1] * r.v[1] + v[2] * r.v[2] + v[3] * r.v[3]; }
  vec4 perspectiveDivide() const { float r = 1.0f / v[3]; return vec4(v[0]*r, v[1]*r, v[2]*r, v[3]*r); }
  vec4 normalise() { return *this * lengthRecip(); }
  vec4 min(vec4 &r) { return vec4(v[0] < r[0] ? v[0] : r[0], v[1] < r[1] ? v[1] : r[1], v[2] < r[2] ? v[2] : r[2], v[3] < r[3] ? v[3] : r[3]); }
  vec4 max(vec4 &r) { return vec4(v[0] >= r[0] ? v[0] : r[0], v[1] >= r[1] ? v[1] : r[1], v[2] >= r[2] ? v[2] : r[2], v[3] >= r[3] ? v[3] : r[3]); }
  float length() { return sqrtf(dot(*this)); }
  float lengthRecip() { return 1.0f/sqrtf(dot(*this)); }
  float lengthSquared() { return dot(*this); }
  vec4 abs() const { return vec4(fabsf(v[0]), fabsf(v[1]), fabsf(v[2]), fabsf(v[3])); }
  bool operator <(const vec4 &r) { return v[0] < r.v[0] && v[1] < r.v[1] && v[2] < r.v[2] && v[3] < r.v[3]; }
  bool operator <=(const vec4 &r) { return v[0] <= r.v[0] && v[1] <= r.v[1] && v[2] <= r.v[2] && v[3] <= r.v[3]; }
  vec4 xyz() const { return vec4(v[0], v[1], v[2], 0); }
  vec4 qmul(const vec4 &r) const {
    return vec4(
	    v[0] * r.v[3] + v[3] * r.v[0] + v[1] * r.v[2] - v[2] * r.v[1],
		  v[1] * r.v[3] + v[3] * r.v[1] + v[2] * r.v[0] - v[0] * r.v[2],
		  v[2] * r.v[3] + v[3] * r.v[2] + v[0] * r.v[1] - v[1] * r.v[0],
		  v[3] * r.v[3] - v[0] * r.v[0] - v[1] * r.v[1] - v[2] * r.v[2]
    );
  }
  vec4 cross(const vec4 &r) const {
    return vec4(
      v[1] * r.v[2] - v[2] * r.v[1],
	    v[2] * r.v[0] - v[0] * r.v[2],
	    v[0] * r.v[1] - v[1] * r.v[0],
	    0
	  );
  }

  float *get() { return &v[0]; }

  const float *get() const { return &v[0]; }

  /*void dump() const {
    printf("{%.3f, %.3f, %.3f, %.3f}\n", v[0], v[1], v[2], v[3]);
  }*/

  const char *toString() const
  {
    static char buf[4][64];
    static int i = 0;
    char *dest = buf[i++&3];
    sprintf_s(dest, sizeof(buf[0]), "{%.3f, %.3f, %.3f, %.3f}", v[0], v[1], v[2], v[3]);
    return dest;
  }
};
#endif

class quat : public vec4
{
public:
  quat(float x, float y, float z, float w) : vec4(x, y, z, w) {}
  quat(const vec4 &r) { *(vec4*)this = r; }
  quat operator*(const quat &r) const { return quat(qmul(r)); }
  quat operator*(float r) const { return quat((vec4&)*this * r); }
  quat &operator*=(const quat &r) { *(vec4*)this = qmul(r); return *this; }
  quat conjugate() const { return qconj(); }
  vec4 rotate(const vec4 &r) const { return (*this * r) * conjugate(); }
};
