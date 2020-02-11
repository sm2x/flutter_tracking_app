import 'package:flutter/material.dart';
import 'package:flutter_tracking_app/api-services/traccar_client.service.dart';
import 'package:flutter_tracking_app/providers/app_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tracking_app/utilities/common_functions.dart';
import 'package:flutter_tracking_app/utilities/constants.dart';
import 'package:flutter_tracking_app/widgets/auth/persistant-footer-buttons.dart';
import 'package:provider/provider.dart';

void main() => runApp(Login());

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginLayout();
  }
}

class LoginLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginLayoutState();
  }
}

class LoginLayoutState extends State<LoginLayout> {
  AppProvider _appProvider;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final userNameController = TextEditingController(text: 'admin');
  final passwordController = TextEditingController(text: 'monarch@account14');
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

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
            if (_formKey.currentState.validate()) {
              setState(() => _loading = true);
              final username = userNameController.text;
              final password = passwordController.text;
              await TraccarClientService().login(username: username, password: password);
              CommonFunctions.showSuccess(_scaffoldKey, username + "  " + password);
              setState(() => _loading = false);
              _appProvider.setLoggedIn(status: true);
              Navigator.pushNamed(context, '/Home');
            }
          } catch (error) {
            print(error);
            CommonFunctions.showError(_scaffoldKey, error.toString());
            setState(() => _loading = false);
          }
        },
      ),
    );
  }

  //Signup Button
  Widget signupButton(BuildContext context) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(36),
      color: kLoginWidgetsColor,
      child: MaterialButton(
        // minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(right: 20.0), child: _loading ? progressIndicator() : signinIcon()),
              Text(
                'Signup',
                style: TextStyle(color: Colors.white, fontSize: 22.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        onPressed: () async {
          CommonFunctions.showSuccess(_scaffoldKey, 'Signup Please');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    if (_appProvider.getLoggedIn()) {
      Navigator.pushNamed(context, '/Home');
    }
    final usernameField = TextFormField(
      controller: userNameController,
      cursorColor: Colors.white,
      decoration: InputDecoration(labelText: 'Username'),
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Username is required';
        }
        return null;
      },
    );
    final passwordField = TextFormField(
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
      ),
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
        }
        return null;
      },
    );

    return Scaffold(
      backgroundColor: kLoginBackgroundColor,
      key: _scaffoldKey,
      body: SingleChildScrollView(
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
                      height: MediaQuery.of(context).size.height - 120,
                      child: Column(
                        children: <Widget>[
                          //Image
                          Stack(
                            children: <Widget>[
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(blurRadius: 2.0, color: Colors.grey),
                                  ],
                                  borderRadius:
                                      BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                  image: DecorationImage(
                                      image: ExactAssetImage('assets/images/login4.jpg'), fit: BoxFit.fill),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.all(36),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 10.0),
                                Text(
                                  'Login To Manage Your Fleet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                usernameField,
                                SizedBox(height: 15.0),
                                passwordField,
                                SizedBox(
                                  height: 20.0,
                                ),
                                loginButton(context),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Row(
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
                                ),
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
      ),
      persistentFooterButtons: FooterButtons(Colors.white).getFooterButtons(context),
    );
  }
}
