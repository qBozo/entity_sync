import 'package:entity_sync/entity_sync.dart';
import 'package:meta/meta.dart';

class UseEntitySync {
  final String baseClassName; 
  final List<SerializableField> fields;
  final SerializableField? keyField;
  final SerializableField? flagField;
  final SerializableField? remoteKeyField;

  const UseEntitySync(
    this.baseClassName, {
    this.fields = const [],
    this.keyField,
    this.flagField,
    this.remoteKeyField,
  });
}

@pragma('dart2js:noInline')
@Target({TargetKind.classType})
class UseSyncable {
  const UseSyncable();
}
