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
  ValueNotifier<double> power = ValueNotifier<double>(5);
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
        power.value = value;
      },
    );
  }

  Vector3 calcAcc() {
    double cl = 0.5; // coefficient of lift
    double cd = 0.5; // coefficient of drag
    double rho = 1.2; // air density kg/m^3 - assume const for now

    // force up - kg/m^3 * m/s * m/s * m^2 -> kg.m/s^2 -> N
    double lift = cl * 0.5 * (rho * v.value.x * v.value.x) * size.x * size.y;
    // force down - kg * m/s^2 -> kg.m/s^2 -> N
    double gravity = mass * 9.81;

    // force forward
    double thrust = power.value * 1000;
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
    Vector3 globalAcc = Vector3(
          localForces.x * cos(angles.value.y) +
              localForces.z * sin(angles.value.y) +
              localForces.x * cos(angles.value.z) +
              localForces.y * sin(angles.value.z),
          localForces.y * cos(angles.value.z) +
              localForces.x * sin(angles.value.z) +
              localForces.y * cos(angles.value.x) +
              localForces.z * sin(angles.value.x),
          localForces.z * cos(angles.value.y) +
              localForces.x * sin(angles.value.y) +
              localForces.z * cos(angles.value.x) +
              localForces.y * sin(angles.value.x) -
              gravity,
        ) /
        mass;

    print(globalAcc);
    return globalAcc;
  }

  // given acceleration update velocity and position
  void updateInertia(double t) {
    double maxV = 2;
    double maxA = 10;
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
    if (acc.z > maxA / 2) {
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
    if (tempV.z > maxV / 20) {
      tempV.z = maxV / 20;
    }
    v.value = tempV;

    // position
    s.value = (a.value * 0.5 * t * t) + (v.value * t) + s.value;
  }

  void updateAngles(Vector2 relativeDelta) {
    // pitch(y), yaw(z), roll(x)
    Vector3 anglesChanged = angles.value +
        Vector3(
          relativeDelta.x / size.length +
              (Random().nextDouble() * (20 / mass) - (10 / mass)),
          relativeDelta.y / size.length +
              (Random().nextDouble() * (20 / mass) - (10 / mass)),
          0,
        );

    const double fullCircleRad = 6.28319;

    // max/min pitch
    if (anglesChanged.y > fullCircleRad / 4) {
      anglesChanged.y = fullCircleRad / 4;
    } else if (anglesChanged.y < -fullCircleRad / 4) {
      anglesChanged.y = -fullCircleRad / 4;
    }

    // after 360 deg reset to 0 deg
    if (anglesChanged.x >= fullCircleRad) {
      anglesChanged = Vector3(
        anglesChanged.x - fullCircleRad,
        anglesChanged.y,
        anglesChanged.z,
      );
    }
    if (anglesChanged.y >= fullCircleRad) {
      anglesChanged = Vector3(
        anglesChanged.x,
        anglesChanged.y - fullCircleRad,
        anglesChanged.z,
      );
    }
    if (anglesChanged.z >= fullCircleRad) {
      anglesChanged = Vector3(
        anglesChanged.x,
        anglesChanged.y,
        anglesChanged.z - fullCircleRad,
      );
    }

    angles.value = anglesChanged;
  }
}
