import 'package:delete_china_apps/alternate.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:uninstall_apps/uninstall_apps.dart';
import 'package:url_launcher/url_launcher.dart';
import "./apps.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remove China Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Delete China Apps'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int flexContainer = 1;

  bool _isAwesome = false;
  bool _isSearched = false;
  bool _isLoading = false;
  List<AlternateApps> _alternateApp;
  List<Application> deviceApps;
  List<Widget> _alternateAppWidget;

  _removeApp(int index) async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      deviceApps.removeAt(index);
    });
  }

  _unInstallApp(String pkg, int index) async {
    await UninstallApps.uninstall(pkg);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      deviceApps.removeAt(index);
      _isAwesome = deviceApps.length == 0;
    });
  }

  _scanForApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
    );

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    print(apps.length);

    List<Application> tempApps = [];

    for (int i = 0; i < apps.length; i++) {
      for (int j = 0; j < chineseApp.length; j++) {
        if (chineseApp[j].packageName == apps[i].packageName) {
          print(apps[i].packageName);
          tempApps.add(apps[i]);
        }
      }
    }

    setState(() {
      deviceApps = tempApps;
      _isLoading = false;
      flexContainer = 1;
      _isSearched = true;
      _isAwesome = deviceApps.length == 0;
    });
  }

  List<Widget> _alternateAppWidgets(String package) {
    _alternateAppWidget = new List<Widget>();
    for (int i = 0; i < chineseApp.length; i++) {
      if (chineseApp[i].packageName == package) {
        for (int j = 0; j < chineseApp[i].alternative.length; j++) {
          _alternateAppWidget.add(Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Image(
                  image: NetworkImage(chineseApp[i].alternative[j].appIcon) ??
                      AssetImage("assets/success.png"),
                  width: 35.0,
                  height: 35.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  chineseApp[i].alternative[j].altName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _launchInBrowser(chineseApp[i].alternative[j].link);
                    });
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Text(
                          'Install',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.file_download)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        }
      }
    }
    return _alternateAppWidget;
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3f51b5),
        title: Center(child: Text(widget.title)),
        elevation: 0.0,
      ),
      body: Container(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: flexContainer,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xff3f51b5),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0))),
                child: _isAwesome
                    ? Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Image.asset(
                          "assets/success.png",
                          height: 150,
                          width: 150,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Image.asset(
                          "assets/dragon.png",
                          height: 150,
                          width: 150,
                        ),
                      ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _isAwesome
                          ? Center(
                              child: Container(
                                child: Text(
                                  "You are awesome, No China Apps found",
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    color: Colors.black45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : !_isSearched && !_isAwesome
                              ? Center(
                                  child: Container(
                                    child: Text(
                                      "Scan For Chinese Apps",
                                      style: TextStyle(
                                        fontSize: 25.0,
                                        color: Colors.black45,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemBuilder: (context, index) {
                                    Application app = deviceApps[index];

                                    return ExpandableNotifier(
                                      child: Column(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 0.0),
                                            leading: app is ApplicationWithIcon
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        MemoryImage(app.icon),
                                                    backgroundColor:
                                                        Colors.white,
                                                  )
                                                : null,
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(app.appName),
                                                Text(
                                                  app.packageName,
                                                  style: TextStyle(
                                                      color: Colors.black45),
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                _unInstallApp(
                                                  deviceApps[index].packageName,
                                                  index,
                                                );
                                                // _removeApp(index);
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: ScrollOnExpand(
                                              scrollOnExpand: true,
                                              scrollOnCollapse: false,
                                              child: ExpandablePanel(
                                                theme:
                                                    const ExpandableThemeData(
                                                  headerAlignment:
                                                      ExpandablePanelHeaderAlignment
                                                          .center,
                                                  tapBodyToCollapse: true,
                                                ),
                                                header: Text('Alternate App'),
                                                expanded: Column(
                                                  children:
                                                      _alternateAppWidgets(
                                                          app.packageName),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    );
                                  },
                                  itemCount: deviceApps.length,
                                ),
                )),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 100,
                vertical: 15,
              ),
              child: Text(
                "SCAN NOW",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Color(0xff3f51b5),
              onPressed: () {
                _scanForApps();
                setState(() {
                  _isLoading = true;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
