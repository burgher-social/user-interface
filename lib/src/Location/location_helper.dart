import 'package:burgher/src/Utils/Location.dart';

import '../Utils/api.dart';

updateLocation() async {
  try {
    print("calling location update");
    var pos = await determineLocation();
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
    return await determinePosition();
  } catch (e) {
    print(e);
    print("error in fetching location");
  }
  return await getLocationHelper();
}
