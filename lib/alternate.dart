class Apps {
  String name;
  String packageName;
  List<AlternateApps> alternative;
  Apps({this.name, this.packageName, this.alternative});
}

class AlternateApps {
  String altName;
  String link;
  String appIcon;
  AlternateApps({this.altName, this.appIcon, this.link});
}
