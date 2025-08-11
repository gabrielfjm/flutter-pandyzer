import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/http/services/DashboardIndicatorsService.dart';

mixin HomeRepository{
  //DASHBOARD INDICATORS
  static Future<DashboardIndicators> getIndicatorsByUserId() async{
    return await DashboardIndicatorsService.getIndicatorsByUserId();
  }
}