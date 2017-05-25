import 'package:fluro/fluro.dart';
import './route_handlers.dart';

class Routes {

  static String demoSimple = "/demo";
  static String demoFunc = "/demo/func";
  static String deepLink = "/message";

  static void configureRoutes(Router router) {
    router.define(demoSimple, handler: demoRouteHandler);
    router.define(demoFunc, handler: demoFunctionHandler);
    router.define(deepLink, handler: deepLinkHandler);
  }

}