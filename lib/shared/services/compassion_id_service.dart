import 'package:kitoapp/shared/models/compassion_id.dart';
import 'package:kitoapp/shared/services/database/app_database.dart';

class CompassionIdService {
  CompassionIdService({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<CompassionId>> fetchAvailableIds() {
    return _database.getAvailableCompassionIds();
  }

  Future<void> assignId(int id) {
    return _database.markCompassionIdAssigned(id);
  }
}
