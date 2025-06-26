// Union Square to Times Square Route - Enhanced with Zones & POIs
// Following your exact driving path coordinates with strategic geotriggers

class DemoConfig {
  // Using actual driving coordinates from real route data

  // Driving behavior settings
  static const double drivingSpeed =
      10; // m/s (15 mph - realistic NYC traffic)
  static const double poiBufferDistance =
      50.0; // meters - early notification for drivers
  static const double zoneBufferDistance =
      25.0; // meters - time to react while driving
  static const double initialZoomScale = 12000.0; // Wider view for driving

  //️ ROUTE: Union Square → Times Square (reverse route, northbound on Broadway)
  static const List<double> startLocation = [
    -73.9912241,
    40.7359009,
  ]; // Union Square
  static const List<double> endLocation = [
    -73.9860104,
    40.7565275,
  ]; // Times Square

  // YOUR EXACT DRIVING PATH - Unchanged
  static const List<List<double>> drivingPath = [
    // START: Union Square
    [-73.9912241, 40.7359009], // Union Square - Broadway & 14th St
    [-73.9916547, 40.7360706], // Broadway northbound
    [-73.9919294, 40.7361857], // Broadway continuing north
    [-73.9920908, 40.7362531], // Broadway at 15th Street
    [-73.9923359, 40.7363579], // Broadway between 15th-16th
    [-73.9924761, 40.7364183], // Broadway at 16th Street
    [-73.9927119, 40.7365178], // Broadway between 16th-17th
    [-73.9931235, 40.7367001], // Broadway at 17th Street
    [-73.9938001, 40.7369931], // Broadway between 17th-18th
    [-73.9943726, 40.7372237], // Broadway at 18th Street
    [-73.9944803, 40.7372710], // Broadway between 18th-19th
    [-73.9945975, 40.7373267], // Broadway at 19th Street
    [-73.9950034, 40.7374806], // Broadway between 19th-20th
    [-73.9954231, 40.7376585], // Broadway at 20th Street
    [-73.9959759, 40.7378921], // Broadway between 20th-21st
    [-73.9961100, 40.7379490], // Broadway at 21st Street
    [-73.9962516, 40.7380109], // Broadway between 21st-22nd
    [-73.9963407, 40.7380490], // Broadway at 22nd Street
    [-73.9958785, 40.7386904], // Broadway between 22nd-23rd
    [-73.9954448, 40.7392799], // Broadway at 23rd Street
    [-73.9953618, 40.7393926], // Broadway between 23rd-24th
    [-73.9952405, 40.7395565], // Broadway at 24th Street
    [-73.9951235, 40.7397165], // Broadway between 24th-25th
    [-73.9950065, 40.7398687], // Broadway at 25th Street
    [-73.9949225, 40.7399854], // Broadway between 25th-26th
    [-73.9947415, 40.7402374], // Broadway at 26th Street
    [-73.9945958, 40.7404506], // Broadway between 26th-27th
    [-73.9945105, 40.7405575], // Broadway at 27th Street
    [-73.9943778, 40.7407420], // Broadway between 27th-28th
    [-73.9942416, 40.7409311], // Broadway at 28th Street
    [-73.9941655, 40.7410389], // Broadway between 28th-29th
    [-73.9940979, 40.7411307], // Broadway at 29th Street
    [-73.9940761, 40.7411673], // Broadway between 29th-30th
    [-73.9939726, 40.7413045], // Broadway at 30th Street
    [-73.9938602, 40.7414575], // Broadway between 30th-31st
    [-73.9937421, 40.7416180], // Broadway at 31st Street
    [-73.9935593, 40.7418720], // Broadway between 31st-32nd
    [-73.9935044, 40.7419485], // Broadway at 32nd Street (Koreatown)
    [-73.9933693, 40.7421421], // Broadway between 32nd-33rd
    [-73.9933628, 40.7421495], // Broadway at 33rd Street
    [-73.9932869, 40.7422404], // Broadway between 33rd-34th
    [-73.9931992, 40.7423560], // Broadway at 34th Street
    [-73.9930848, 40.7425110], // Broadway between 34th-35th
    [-73.9930138, 40.7426115], // Broadway at 35th Street
    [-73.9929647, 40.7426802], // Broadway between 35th-36th
    [-73.9929356, 40.7427207], // Broadway at 36th Street
    [-73.9928000, 40.7429071], // Broadway between 36th-37th
    [-73.9927405, 40.7429978], // Broadway at 37th Street
    [-73.9927044, 40.7430501], // Broadway between 37th-38th
    [-73.9926205, 40.7431663], // Broadway at 38th Street
    [-73.9925561, 40.7432554], // Broadway between 38th-39th
    [-73.9924092, 40.7434577], // Broadway at 39th Street
    [-73.9923200, 40.7435800], // Broadway between 39th-40th
    [-73.9922368, 40.7436910], // Broadway at 40th Street
    [-73.9921253, 40.7438422], // Broadway between 40th-41st
    [-73.9919892, 40.7440266], // Broadway at 41st Street
    [-73.9918671, 40.7441923], // Broadway between 41st-42nd
    [-73.9918109, 40.7442685], // Broadway at 42nd Street (Times Square)
    [-73.9917817, 40.7443080], // Broadway in Times Square
    [-73.9916903, 40.7444318], // Broadway continuing through Times Square
    [-73.9914958, 40.7446975], // Broadway at 43rd Street
    [-73.9914606, 40.7447467], // Broadway between 43rd-44th
    [-73.9914079, 40.7448195], // Broadway at 44th Street
    [-73.9913304, 40.7449263], // Broadway between 44th-45th
    [-73.9912663, 40.7450144], // Broadway at 45th Street
    [-73.9912291, 40.7450655], // Broadway between 45th-46th
    [-73.9912215, 40.7450764], // Broadway at 46th Street
    [-73.9911414, 40.7451906], // Broadway between 46th-47th
    [-73.9909714, 40.7454283], // Broadway at 47th Street
    [-73.9909223, 40.7454955], // Broadway between 47th-48th
    [-73.9905754, 40.7459713], // Broadway at 48th Street
    [-73.9905218, 40.7460449], // Broadway between 48th-49th
    [-73.9904666, 40.7461206], // Broadway at 49th Street
    [-73.9903060, 40.7463409], // Broadway between 49th-50th
    [-73.9902374, 40.7464351], // Broadway at 50th Street
    [-73.9901702, 40.7465270], // Broadway between 50th-51st
    [-73.9901256, 40.7465882], // Broadway at 51st Street
    [-73.9900660, 40.7466697], // Broadway between 51st-52nd
    [-73.9896215, 40.7472838], // Broadway at 52nd Street
    [-73.9893444, 40.7476673], // Broadway between 52nd-53rd
    [-73.9892782, 40.7477535], // Broadway at 53rd Street
    [-73.9892597, 40.7477788], // Broadway between 53rd-54th
    [-73.9891707, 40.7479007], // Broadway at 54th Street
    [-73.9887112, 40.7485074], // Broadway between 54th-55th
    [-73.9885754, 40.7486891], // Broadway at 55th Street
    [-73.9884589, 40.7488506], // Broadway between 55th-56th
    [-73.9883800, 40.7489572], // Broadway at 56th Street
    [-73.9882934, 40.7490772], // Broadway between 56th-57th
    [-73.9882528, 40.7491332], // Broadway at 57th Street
    [-73.9882084, 40.7491918], // Broadway between 57th-58th
    [-73.9881810, 40.7492289], // Broadway at 58th Street
    [-73.9879751, 40.7495003], // Broadway between 58th-59th
    [-73.9878563, 40.7496621], // Broadway at 59th Street
    [-73.9877963, 40.7497442], // Broadway between 59th-60th
    [-73.9877543, 40.7498008], // Broadway at 60th Street
    [-73.9876815, 40.7498979], // Broadway between 60th-61st
    [-73.9876234, 40.7499773], // Broadway at 61st Street
    [-73.9874344, 40.7502249], // Broadway between 61st-62nd
    [-73.9872685, 40.7504565], // Broadway at 62nd Street
    [-73.9872243, 40.7505210], // Broadway between 62nd-63rd
    [-73.9871922, 40.7505681], // Broadway at 63rd Street
    [-73.9871077, 40.7506941], // Broadway between 63rd-64th
    [-73.9870366, 40.7507999], // Broadway at 64th Street
    [-73.9869300, 40.7509586], // Broadway between 64th-65th
    [-73.9869182, 40.7509762], // Broadway at 65th Street
    [-73.9868451, 40.7510913], // Broadway between 65th-66th
    [-73.9866443, 40.7513682], // Broadway at 66th Street
    [-73.9863773, 40.7517055], // Broadway between 66th-67th
    [-73.9863059, 40.7518051], // Broadway at 67th Street
    [-73.9861716, 40.7519908], // Broadway between 67th-68th
    [-73.9860244, 40.7521945], // Broadway at 68th Street
    [-73.9860093, 40.7522154], // Broadway between 68th-69th
    [-73.9859394, 40.7523121], // Broadway at 69th Street
    [-73.9858524, 40.7524328], // Broadway between 69th-70th
    [-73.9857231, 40.7526110], // Broadway at 70th Street
    [-73.9855593, 40.7528378], // Broadway between 70th-71st
    [-73.9854848, 40.7529410], // Broadway at 71st Street
    [-73.9854362, 40.7530112], // Broadway between 71st-72nd
    [-73.9852738, 40.7532329], // Broadway at 72nd Street
    [-73.9851751, 40.7533696], // Broadway between 72nd-73rd
    [-73.9850400, 40.7535567], // Broadway at 73rd Street
    [-73.9849740, 40.7536467], // Broadway between 73rd-74th
    [-73.9848572, 40.7538099], // Broadway at 74th Street
    [-73.9846759, 40.7540610], // Broadway between 74th-75th
    [-73.9845924, 40.7541767], // Broadway at 75th Street
    [-73.9844996, 40.7543053], // Broadway between 75th-76th
    [-73.9843592, 40.7544998], // Broadway at 76th Street
    [-73.9842315, 40.7546791], // Broadway between 76th-77th
    [-73.9841117, 40.7548472], // Broadway at 77th Street
    [-73.9838047, 40.7552777], // Broadway between 77th-78th
    [-73.9837365, 40.7553691], // Broadway at 78th Street
    [-73.9836702, 40.7554576], // Broadway between 78th-79th
    [-73.9836222, 40.7555220], // Broadway at 79th Street
    [-73.9850989, 40.7561440], // Transition to 7th Avenue
    [-73.9854152, 40.7562771], // 7th Avenue northbound
    [-73.9857329, 40.7564107], // 7th Avenue continuing north
    [-73.9860104, 40.7565275], // Times Square destination
  ];

  // ESSENTIAL GEOTRIGGER ZONES - Spread evenly along the route
  static const List<Map<String, dynamic>> geotriggerZones = [
    {
      'name': 'Union Square',
      'center': [-73.9912241, 40.7359009],
      'radius': 120.0,
      'priority': 'critical',
      'type': 'start',
      'message':
          'Starting at Union Square! Historic gathering place and farmers market.',
    },
    {
      'name': 'Flatiron District',
      'center': [-73.9954448, 40.7392799], // Broadway at 23rd Street
      'radius': 140.0,
      'priority': 'high',
      'type': 'neighborhood',
      'message':
          'Passing through Flatiron District - famous triangular building nearby.',
    },
    {
      'name': 'Theater District',
      'center': [-73.9912663, 40.7450144], // Broadway at 45th Street
      'radius': 160.0,
      'priority': 'high',
      'type': 'entertainment',
      'message': 'Heart of Broadway! Famous theaters and shows all around.',
    },
    {
      'name': 'Central Park South',
      'center': [-73.9885754, 40.7486891], // Broadway at 55th Street
      'radius': 150.0,
      'priority': 'medium',
      'type': 'park',
      'message': 'Approaching Central Park! The green heart of Manhattan.',
    },
    {
      'name': 'Columbus Circle',
      'center': [-73.9854848, 40.7529410], // Broadway at 71st Street
      'radius': 140.0,
      'priority': 'medium',
      'type': 'landmark',
      'message':
          'Columbus Circle! Gateway to Central Park and Upper West Side.',
    },
    {
      'name': 'Times Square Destination',
      'center': [-73.9860104, 40.7565275], // Final destination
      'radius': 120.0,
      'priority': 'critical',
      'type': 'destination',
      'message': 'Arrived at Times Square! The crossroads of the world.',
    },
  ];

  // KEY POINTS OF INTEREST - Distributed along the entire route
  static const List<Map<String, dynamic>> pointsOfInterest = [
    {
      'name': 'Flatiron Building',
      'coordinates': [-73.9896988, 40.7410605], // Around 23rd Street area
      'buffer': 120.0,
      'description': 'Iconic 1902 triangular skyscraper',
      'category': 'landmark',
      'importance': 'critical',
    },
    {
      'name': 'Herald Square',
      'coordinates': [-73.9931992, 40.7423560], // 34th Street area
      'buffer': 100.0,
      'description': 'Major shopping district and Macy\'s flagship store',
      'category': 'shopping',
      'importance': 'high',
    },
    {
      'name': 'Broadway Theaters',
      'coordinates': [
        -73.9909714,
        40.7454283,
      ], // 47th Street - Theater District
      'buffer': 150.0,
      'description': 'Heart of Broadway with world-famous shows',
      'category': 'entertainment',
      'importance': 'critical',
    },
    {
      'name': 'Times Square Ball',
      'coordinates': [-73.9860104, 40.7565275], // Final destination
      'buffer': 90.0,
      'description': 'Famous New Year\'s Eve ball drop location',
      'category': 'landmark',
      'importance': 'critical',
    },
  ];

  // COMPLETION DETECTION
  static bool isNearTimesSquare(double lat, double lon) {
    const double timesSquareLat = 40.7565275;
    const double timesSquareLon = -73.9860104;
    const double threshold = 0.0008; // About 80 meters

    final double latDiff = (lat - timesSquareLat).abs();
    final double lonDiff = (lon - timesSquareLon).abs();

    return latDiff < threshold && lonDiff < threshold;
  }
}
