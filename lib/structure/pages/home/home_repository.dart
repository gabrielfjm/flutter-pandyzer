import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/http/models/Log.dart';
import 'package:flutter_pandyzer/structure/http/services/DashboardIndicatorsService.dart';
import 'package:flutter_pandyzer/structure/http/services/log_service.dart';

mixin HomeRepository{
  //DASHBOARD INDICATORS
  static Future<DashboardIndicators> getIndicatorsByUserId() async{
    return await DashboardIndicatorsService.getIndicatorsByUserId();
  }

  //LOGS
  static Future<List<Log>> getActivityLogs(int userId) async{
    return await LogService.getActivityLogs(userId);
  }
}