import 'package:burgher/src/Utils/Location.dart';

import '../Utils/api.dart';

updateLocation() async {
  try {
    print("calling location update");
    var pos = await determineLocation();
    print(pos);
    print("Calling API loc crate");
    await callApi("/location/create", true, {
      "latitude": pos.latitude,
      "longitude": pos.longitude,
    });
  } catch (e) {
    print(e);
  }
}

Future<bool> getLocationHelper() async {
  try {
    print("getting location");
    var pos = await determineLocation();
    return true;
  } catch (e) {
    print(e);
    print("error in fetching location");
  }
  return await getLocationHelper();
}
