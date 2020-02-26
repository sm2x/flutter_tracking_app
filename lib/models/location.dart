class LocationCustom {
  double latitude;
  double longitude;
  LocationCustom({this.latitude, this.longitude});
  Map<String, double> toMAP() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
