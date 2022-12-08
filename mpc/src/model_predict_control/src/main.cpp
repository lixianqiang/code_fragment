#include <casadi/casadi.hpp>
#include <casadi/core/function.hpp>
#include <casadi/core/slice.hpp>
#include <casadi/core/sparsity_interface.hpp>
#include <cstddef>
#include "mpc_single_shooting.h"

int main(int argc, char** argv)
{
  int N = 10;
  float l = 1.2;

  casadi::SX x = casadi::SX::sym("x");
  casadi::SX y = casadi::SX::sym("y");
  casadi::SX theta = casadi::SX::sym("theta");
  casadi::SX states = casadi::SX::vertcat({ x, y, theta });
  int n_states = states.size1();

  casadi::SX v = casadi::SX::sym("v");
  casadi::SX phi = casadi::SX::sym("phi");
  casadi::SX controls = casadi::SX::vertcat({ v, phi });
  int n_controls = controls.size1();

  // we pass states and controls as the function inputs and it returns rhs matrix using casADAi
  casadi::SX rhs = casadi::SX::vertcat({ v * cos(theta), v * sin(theta), 2 * v * tan(phi) / l });
  auto f = casadi::Function("f", { states, controls }, { rhs });

  // U: Decision/control variables
  // P: parameters vector which is [p_0, p_1, p_2, p_3, p_4, p_5] parameters (which include the initial and the
  //    reference state of the robot)
  // X: prediction of states A Matrix that represents the states over the prediction steps. So X represents the
  // prediction
  //    of states contains 3 rows and N+1 columns
  casadi::SX U = casadi::SX::sym("U", n_controls, N);
  casadi::SX P = casadi::SX::sym("P", n_states + n_states);
  casadi::SX X = casadi::SX::sym("X", n_states, N + 1);

  // initial state of X (prediction states) is the first three
  X(casadi::Slice(), casadi::Slice(0)) = P(casadi::Slice(0, 3), casadi::Slice());

  for (size_t k = 0; k < N - 1; k++)
  {
    casadi::SX st = X(casadi::Slice(), casadi::Slice(k));
    casadi::SX con = U(casadi::Slice(), casadi::Slice(k));
    //     f_value = f(st, con);
    // st_next = st + (T * f_value); % it gives us next state
    // X(:, k + 1) = st_next;
  }

  // this function to get the optimal trajectory knowing the optimal solution
  // it calculates the state predictions when we pass optimization variable U and Parameter matrix P
  auto ff = casadi::Function("ff", { U, P }, { X });

  //   %% calculate objective function
  casadi::SX obj = 0;
  casadi::SX g = casadi::SX::vertcat({});

  // weighing matrices (states)
  casadi::SX Q = casadi::SX::zeros(3, 3);
  Q(0, 0) = 1;
  Q(1, 1) = 5;
  Q(2, 2) = 0.2;

  // weighing matrices (controls)
  casadi::SX R = casadi::SX::zeros(2, 2);
  R(0, 0) = 0.01;
  R(1, 1) = 0.09;

  // compute objective
  for (size_t k = 0; k < N; k++)
  {
    casadi::SX st = X(casadi::Slice(), casadi::Slice(k));
    casadi::SX con = U(casadi::Slice(), casadi::Slice(k));
    obj += (st - P(casadi::Slice(4, 6), casadi::Slice())).T() * Q * (st - P(casadi::Slice(4, 6), casadi::Slice())) +
           con.T() * R * con;
  }

  // compute constraints
  for (size_t k = 0; k < N; k++)
  {
    //  g = [g; X(1, k)] % state x, first entry of each column
    // g = [g; X(2, k)] % state y, second entry of each column
    // g = [g; X(3, k)] % state theta, third entry of each column
  }

  // make the decision variables one column vector
  auto OPT_variables = casadi::reshape(U, 2 * N, 1);
  // make the parameters one column vector
  auto OPT_parameters = casadi::reshape(P, 6, 1);
}