<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Need to integrate a payment checkout engine for you flutter app? This package is the easiest way to do it
## Features

Pay with transfer. Pay with card and pay with bank coming soon

## Getting started
In order to use this package for your app, you will need to use the onGenerateRoute system for routing,
this is because you will have to pass both your checkout page name route and your callback page name route.

Upon payment successful, you will receieve a string json as a returned value on your callback page
## Usage


```dart
class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => Checkout());
      case '/checkout':
        return MaterialPageRoute(builder: (_) => Checkout());
      case '/callback':
        if(args is String){
          return MaterialPageRoute(
              builder: (_) => CallbackPage(response: args)
          );
        }

        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
```

## Additional information


