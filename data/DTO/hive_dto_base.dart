/// DTO for storing objects in local memory.
///
/// data - The data itself, required to be stored
///
/// lifeTime - lifetime of the object in seconds. If the value is -1, the lifetime of the object will never expire
abstract class HiveDTO {
  final Object data;
  late final DateTime createdIn;
  final int lifeTime;

  HiveDTO(this.data, {this.lifeTime = -1}) {
    createdIn = DateTime.now();
  }
}
