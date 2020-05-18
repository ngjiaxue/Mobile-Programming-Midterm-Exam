class Location {
  String _pid,
      _locName,
      _state,
      _description,
      _latitude,
      _longitude,
      _url,
      _contact,
      _address,
      _imagename;

  Location(
      String pid,
      String locName,
      String state,
      String description,
      String latitude,
      String longitude,
      String url,
      String contact,
      String address,
      String imagename) {
    this._pid = pid;
    this._locName = locName;
    this._state = state;
    this._description = description;
    this._latitude = latitude;
    this._longitude = longitude;
    this._url = url;
    this._contact = contact;
    this._address = address;
    this._imagename = imagename;
  }

  getLocName() {
    return this._locName;
  }

  getDescription() {
    return this._description;
  }

  getLatitude() {
    return this._latitude;
  }

  getLongitude() {
    return this._longitude;
  }

  getUrl() {
    return this._url;
  }

  getAddress() {
    return this._address;
  }

  getContact() {
    return this._contact;
  }

  getImageName() {
    return this._imagename;
  }
}
