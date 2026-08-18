import 'dart:mirrors';
import 'package:pod_player/pod_player.dart';

void main() {
  ClassMirror cm = reflectClass(PodPlayerController);
  for (var m in cm.declarations.values) {
    print(m.simpleName);
  }
}
