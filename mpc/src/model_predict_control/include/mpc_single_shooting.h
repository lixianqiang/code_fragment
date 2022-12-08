#include <math.h>
#include <casadi/casadi.hpp>

#define PI acos(-1)

class ModelPredictiveControl
{
public:
  float T = 0.20;          // sampling time [s]
  int N = 10;              // prediction horizon
  float l = 1.2;           // distance between front and rear wheels [m]
  float v_max = 0.5;       // maximum velocity [m/s]
  float v_min = -0.5;      // minimum velocity [m/s]
  float phi_max = PI / 4;  // maximum steering angle [rad]
};