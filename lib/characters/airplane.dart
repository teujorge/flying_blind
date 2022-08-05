import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'dart:math';

class Airplane {
  // custom fields
  double mass;
  Vector3 size;

  // acc, vel, pos
  ValueNotifier<Vector3> a = ValueNotifier<Vector3>(Vector3.all(0));
  ValueNotifier<Vector3> v = ValueNotifier<Vector3>(Vector3(50, 0, 0));
  ValueNotifier<Vector3> s = ValueNotifier<Vector3>(Vector3.all(10));

  // pitch(y), yaw(z), roll(x)
  ValueNotifier<Vector3> angles = ValueNotifier<Vector3>(Vector3(0, 0, 0));

  // avionics
  SpriteComponent crosshair = SpriteComponent(anchor: Anchor.center);
  SpriteComponent navball = SpriteComponent(anchor: Anchor.center);
  double power = 5;
  late Slider throttleController;

  // constructor
  Airplane({
    required this.mass,
    required this.size,
    required Vector3 position,
  }) {
    s.value = position;

    throttleController = Slider(
      min: 0,
      max: 10,
      value: 5,
      onChanged: (double value) {
        power = value;
      },
    );
  }

  Vector3 calcAcc() {
    double cl = 0.2; // coefficient of lift
    double cd = 0.2; // coefficient of drag
    double rho = 1.2; // air density kg/m^3 - assume const for now

    // force up - kg/m^3 * m/s * m/s * m^2 -> kg.m/s^2 -> N
    double lift = cl * 0.5 * (rho * v.value.x * v.value.x) * size.x * size.y;
    // force down - kg * m/s^2 -> kg.m/s^2 -> N
    double gravity = mass * 9.81;

    // force forward
    double thrust = power * 1000;
    // force backward
    double drag = cd * 0.5 * (rho * v.value.x * v.value.x) * size.z * size.y;

    // print("lift: $lift : gravity: $gravity : thrust: $thrust : drag: $drag");

    Vector3 localForces = Vector3(
      thrust - drag,
      0,
      lift,
    );

    // rot around x
    // y' = x*cos(roll) + z*sin(roll)
    // z' = z*cos(roll) + y*sin(roll)
    // rot around y
    // x' = x*cos(pitch) + z*sin(pitch)
    // z' = z*cos(pitch) + x*sin(pitch)
    // rot around z
    // x' = x*cos(yaw) + y*sin(yaw)
    // y' = y*cos(yaw) + x*sin(yaw)

    // pitch(y), yaw(z), roll(x)
    Vector3 globalForces = Vector3(
      localForces.x * cos(angles.value.y) +
          localForces.z * sin(angles.value.y) +
          localForces.x * cos(angles.value.z) +
          localForces.y * sin(angles.value.z),
      localForces.y * cos(angles.value.z) +
          localForces.x * sin(angles.value.z) +
          localForces.x * cos(angles.value.x) +
          localForces.z * sin(angles.value.x),
      localForces.z * cos(angles.value.y) +
          localForces.x * sin(angles.value.y) +
          localForces.z * cos(angles.value.x) +
          localForces.y * sin(angles.value.x) -
          gravity,
    );

    return globalForces / mass;
  }

  // given acceleration update velocity and position
  void updateInertia(double t) {
    double maxA = 2;
    double maxV = 10;
    Vector3 acc = calcAcc();

    // acceleration
    if (acc.x > maxA) {
      acc.x = maxA;
    } else if (acc.x < -maxA) {
      acc.x = -maxA;
    }
    if (acc.y > maxA) {
      acc.y = maxA;
    } else if (acc.y < -maxA) {
      acc.y = -maxA;
    }
    if (acc.z > maxA) {
      acc.z = maxA / 2;
    }
    a.value = acc;
    // velocity
    Vector3 tempV = (a.value * t) + v.value;
    if (tempV.x > maxV) {
      tempV.x = maxV;
    } else if (tempV.x < -maxV) {
      tempV.x = -maxV;
    }
    if (tempV.y > maxV) {
      tempV.y = maxV;
    } else if (tempV.y < -maxV) {
      tempV.y = -maxV;
    }
    if (tempV.z > maxV) {
      tempV.z = maxV / 20;
    }
    tempV = Vector3(
      1 * cos(angles.value.y) +
          0 * sin(angles.value.y) +
          1 * cos(angles.value.z) +
          0 * sin(angles.value.z),
      0 * cos(angles.value.z) +
          1 * sin(angles.value.z) +
          1 * cos(angles.value.x) +
          0 * sin(angles.value.x),
      0 * cos(angles.value.y) +
          1 * sin(angles.value.y) +
          0 * cos(angles.value.x) +
          0 * sin(angles.value.x) -
          .75,
    );
    v.value = tempV;
    // position
    s.value = (a.value * 0.5 * t * t) + (v.value * t) + s.value;
  }

  // update throttle value
  void updateThrottle(double t) {
    power = t;
    if (angles.value.x >= 360) {
      angles.value =
          Vector3(angles.value.x - 360, angles.value.y, angles.value.z);
    }
    if (angles.value.y >= 360) {
      angles.value =
          Vector3(angles.value.x, angles.value.y - 360, angles.value.z);
    }
    if (angles.value.z >= 360) {
      angles.value =
          Vector3(angles.value.x, angles.value.y, angles.value.z - 360);
    }
  }
}
