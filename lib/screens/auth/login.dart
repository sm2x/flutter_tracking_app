import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/api_services.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:flutter_tracking_app/screens/home/home_page.dart';
import 'package:flutter_tracking_app/widgets/custom_loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/auth/persistant-footer-buttons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginLayoutState();
  }
}

class _LoginLayoutState extends State<Login> {
  AppProvider _appProvider;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _invalidCredentials = false;
  String apiCookie;
  String username;
  String password;

  //Signin Icon
  Widget signinIcon() {
    return Icon(
      FontAwesomeIcons.signInAlt,
      color: Colors.white,
    );
  }

  //ProgressIndicator
  Widget progressIndicator() {
    return SizedBox(
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        strokeWidth: 2.0,
      ),
      height: 22.0,
      width: 22.0,
    );
  }

  //LoginButton
  Widget loginButton(BuildContext context) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(36),
      color: kLoginWidgetsColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(right: 20.0), child: _loading ? progressIndicator() : signinIcon()),
              Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 22.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        onPressed: () async {
          try {
            if (_validateSubmit()) {
              setState(() => _loading = true);
              final username = userNameController.text;
              final password = passwordController.text;
              await TraccarClientService(appProvider: _appProvider).login(username: username, password: password);
              setState(() => _loading = false);
              await _appProvider.setLoggedIn(status: true);
              Navigator.popAndPushNamed(context, '/Home');
            }
          } catch (error) {
            print(error);
            CommonFunctions.showError(_scaffoldKey, 'Unauthorized');
            setState(() => _loading = false);
          }
        },
      ),
    );
  }

  _validateSubmit() {
    if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
      CommonFunctions.showError(_scaffoldKey, 'Invalid Credentials');
      return false;
    }
    return true;
  }

  //Get Cookie From sharedPreferences
  Future getSharedPrefrences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    apiCookie = sharedPreferences.getString(kCookieKey);
    username = sharedPreferences.getString('username');
    password = sharedPreferences.getString('password');
    return Future.value();
  }

  // Build Method //
  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    Widget body;
    if (_appProvider.isLoggedIn == false) {
      body = Scaffold(
        backgroundColor: kLoginBackgroundColor,
        key: _scaffoldKey,
        body: ListView(
          children: <Widget>[
            _singleChildScrollView(),
          ],
        ),
        persistentFooterButtons: FooterButtons(Colors.white).getFooterButtons(context),
      );
    } else {
      body = HomePage();
    }
    return body;
    // Widget loginWidget = Scaffold(
    //   backgroundColor: kLoginBackgroundColor,
    //   key: _scaffoldKey,
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       _singleChildScrollView(),
    //     ],
    //   ),
    //   persistentFooterButtons: FooterButtons(Colors.white).getFooterButtons(context),
    // );
    // body = FutureBuilder(
    //   future: getCookie(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       print(snapshot.data);
    //       String cookie = snapshot.data;
    //       if (cookie != null) {
    //         return Text(cookie);
    //       } else {
    //         return loginWidget;
    //       }
    //     }
    //     return CustomLoader();
    //   },
    // );
    // return body;
  }

  // SingleChildScroll View
  Widget _singleChildScrollView() {
    final usernameField = TextFormField(
      controller: userNameController,
      cursorColor: Colors.white,
      decoration: InputDecoration(labelText: 'Username'),
    );
    final passwordField = TextFormField(
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
      ),
    );
    return FutureBuilder(
        future: getSharedPrefrences(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            userNameController.text = username;
            passwordController.text = password;
            return SingleChildScrollView(
              child: Container(
                color: kLoginBackgroundColor,
                child: Stack(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 1.5)]),
                            height: MediaQuery.of(context).size.height - 150,
                            child: Column(
                              children: <Widget>[
                                //Image
                                _coverImageWidget(),
                                Padding(
                                  padding: const EdgeInsets.all(36),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      usernameField,
                                      SizedBox(height: 5.0),
                                      passwordField,
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      loginButton(context),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return CustomLoader();
        });
  }

  Widget _coverImageWidget() {
    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              image: DecorationImage(image: ExactAssetImage('assets/images/login4.jpg'), fit: BoxFit.fill),
            ),
          ),
        ),
        Positioned(
          top: 65,
          left: 20,
          child: Column(
            children: <Widget>[
              Text(
                kCompanyName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                ' VT Pvt Ltd',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // SignUp widget
  Widget _signupWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Don't have any account ?"),
        SizedBox(
          width: 10,
        ),
        Text(
          'Register',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kLoginWidgetsColor,
          ),
        )
      ],
    );
  }
}
