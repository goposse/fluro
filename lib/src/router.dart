/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
part of fluro;

enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom, // if using custom then you must also provide a transition
}

class Router {
  /// The tree structure that stores the defined routes
  RouteTree _routeTree = new RouteTree();

  /// Generic handler for when a route has not been defined
  Handler notFoundHandler;

  /// Creates a [PageRoute] definition for the passed [RouteHandler]. You can optionally provide a custom
  /// transition builder for the route.
  void define(String routePath, {@required Handler handler}) {
    _routeTree.addRoute(new AppRoute(routePath, handler));
  }

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch match(String path) {
    return _routeTree.matchRoute(path);
  }

  ///
  void navigateTo(BuildContext context, String path, {TransitionType transition = TransitionType.native,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder transitionBuilder})
  {
    RouteMatch routeMatch = matchRoute(context, path, transitionType: transition,
        transitionsBuilder: transitionBuilder, transitionDuration: transitionDuration);
    Route<Null> route = routeMatch.route;
    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      return;
    }
    if (route == null && notFoundHandler != null) {
      route = _notFoundRoute(context, path);
    }
    if (route != null) {
      Navigator.push(context, route);
    } else {
      print("No registered route was found to handle '$path'.");
    }
  }

  ///
  Route<Null> _notFoundRoute(BuildContext context, String path) {
    RouteCreator creator = (RouteSettings routeSettings, Map<String, dynamic> parameters) {
      return new MaterialPageRoute<Null>(settings: routeSettings, builder: (BuildContext context) {
        return notFoundHandler.handlerFunc(context, parameters);
      });
    };
    return creator(new RouteSettings(name: path), null);
  }

  ///
  RouteMatch matchRoute(BuildContext buildContext, String path, {RouteSettings routeSettings = null,
    TransitionType transitionType, Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder transitionsBuilder})
  {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = new RouteSettings(name: path);
    }
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;
    Handler handler = (route != null ? route.handler : notFoundHandler);
    if (route == null && notFoundHandler == null) {
      return new RouteMatch(matchType: RouteMatchType.noMatch, errorMessage: "No matching route was found");
    }
    Map<String, String> parameters = match?.parameters ?? <String, String>{};
    if (handler.type == HandlerType.function) {
      handler.handlerFunc(buildContext, parameters);
      return new RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    RouteCreator creator = (RouteSettings routeSettings, Map<String, dynamic> parameters) {
      bool isNativeTransition = (transitionType == TransitionType.native || transitionType == TransitionType.nativeModal);
      if (isNativeTransition) {
        return new MaterialPageRoute<Null>(settings: routeSettings, fullscreenDialog: transitionType == TransitionType.nativeModal,
            builder: (BuildContext context) {
              return handler.handlerFunc(context, parameters);
            });
      } else {
        var routeTransitionsBuilder;
        if (transitionType == TransitionType.custom) {
          routeTransitionsBuilder = transitionsBuilder;
        } else {
          routeTransitionsBuilder = _standardTransitionsBuilder(transitionType);
        }
        return new PageRouteBuilder<Null>(settings: routeSettings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return handler.handlerFunc(context, parameters);
          },
          transitionDuration: transitionDuration,
          transitionsBuilder: routeTransitionsBuilder,
        );
      }
    };
    return new RouteMatch(
      matchType: RouteMatchType.visual,
      route: creator(settingsToUse, parameters),
    );
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return new FadeTransition(opacity: animation, child: child);
      } else {
        FractionalOffset startOffset = FractionalOffset.bottomLeft;
        FractionalOffset endOffset = FractionalOffset.topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = new FractionalOffset(-1.0, 0.0);
          endOffset = FractionalOffset.topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = FractionalOffset.topRight;
          endOffset = FractionalOffset.topLeft;
        }

        return new SlideTransition(
          position: new FractionalOffsetTween(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<Null> generator(RouteSettings routeSettings) {
    RouteMatch match = matchRoute(null, routeSettings.name, routeSettings: routeSettings);
    return match.route;
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
