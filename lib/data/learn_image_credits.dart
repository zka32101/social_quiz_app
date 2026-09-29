/// "まなぶ" の各学習トピックに表示する参考画像のメタデータ。
///
/// 画像はすべて Wikimedia Commons から取得した CC0 / Public Domain / CC BY 系
/// ライセンスのもの。CC BY 系は作者クレジット表示が利用条件のため、
/// 学習画面側で画像の下に [LearnImageCredit.artist] / [LearnImageCredit.license]
/// を必ず表示すること。
class LearnImageCredit {
  /// pubspec 上のアセットパス（例: 'assets/images/learn/environment/climate.jpg'）
  final String asset;

  /// Wikimedia Commons 上のファイルタイトル
  final String title;

  /// 作者・クレジット表記
  final String artist;

  /// ライセンス表記（例: 'CC BY-SA 4.0', 'Public domain'）
  final String license;

  const LearnImageCredit({
    required this.asset,
    required this.title,
    required this.artist,
    required this.license,
  });
}

/// キー: `<subject>/<sectionId>`（例: 'environment/climate'）
const Map<String, LearnImageCredit> kLearnImageCredits = {
  'civics/constitution': LearnImageCredit(
    asset: 'assets/images/learn/civics/constitution.jpg',
    title: 'File:National Diet Building.jpg',
    artist: 'Kakidai',
    license: 'CC BY-SA 4.0',
  ),
  'civics/elections': LearnImageCredit(
    asset: 'assets/images/learn/civics/elections.jpg',
    title: 'File:Osaka Mayoral Election ballot box 20051127.jpg',
    artist: 'MASA',
    license: 'CC BY-SA 3.0',
  ),
  'civics/local_government': LearnImageCredit(
    asset: 'assets/images/learn/civics/local_government.jpg',
    title: 'File:TokyoMetropolitanGovernmentOffice.jpg',
    artist: 'Markus Leupold-Löwenthal',
    license: 'CC BY-SA 3.0',
  ),
  'civics/national_assembly': LearnImageCredit(
    asset: 'assets/images/learn/civics/national_assembly.jpg',
    title: 'File:House of Councillors Annex.jpg',
    artist: 'Peacearth',
    license: 'CC BY-SA 4.0',
  ),
  'civics/separation_of_powers': LearnImageCredit(
    asset: 'assets/images/learn/civics/separation_of_powers.jpg',
    title: 'File:Supreme Court of Japan-1.jpg',
    artist: '江戸村のとくぞう',
    license: 'CC BY-SA 4.0',
  ),
  'civics/taxes': LearnImageCredit(
    asset: 'assets/images/learn/civics/taxes.jpg',
    title: 'File:New Japan Notes and Coins (Screenshot).png',
    artist: 'Bank of Japan',
    license: 'CC BY 4.0',
  ),
  'environment/climate': LearnImageCredit(
    asset: 'assets/images/learn/environment/climate.jpg',
    title: 'File:Climate change on Cima Brenta. Vedretta Superiore di Brenta like a melting popsicle, summer 2003.JPG',
    artist: 'Frfincon',
    license: 'CC BY-SA 3.0',
  ),
  'environment/energy': LearnImageCredit(
    asset: 'assets/images/learn/environment/energy.jpg',
    title: 'File:Green radio mast with solar panel and wind generator - geograph.org.uk - 608556.jpg',
    artist: 'Jerry Elston',
    license: 'CC BY-SA 2.0',
  ),
  'environment/forest': LearnImageCredit(
    asset: 'assets/images/learn/environment/forest.jpg',
    title: 'File:Sunlight through the Canopy.jpg',
    artist: 'Machli16',
    license: 'CC BY-SA 4.0',
  ),
  'environment/pollution': LearnImageCredit(
    asset: 'assets/images/learn/environment/pollution.jpg',
    title: 'File:KAISER ALUMINUM PLANT SMOKESTACK SPREADS FUMES ABOVE ST CLAUDE AVENUE IN THE CHALMETTE SECTION - NARA - 546074.jpg',
    artist: 'John Messina',
    license: 'Public domain',
  ),
  'environment/recycle': LearnImageCredit(
    asset: 'assets/images/learn/environment/recycle.jpg',
    title: 'File:Plastic recycling bin in Reykjavik cropped.jpg',
    artist: 'Akigka',
    license: 'CC0',
  ),
  'grade3/directions': LearnImageCredit(
    asset: 'assets/images/learn/grade3/directions.jpg',
    title: 'File:Lille rose des vents republique.jpg',
    artist: 'Velvet',
    license: 'CC BY-SA 4.0',
  ),
  'grade3/map_symbols': LearnImageCredit(
    asset: 'assets/images/learn/grade3/map_symbols.jpg',
    title: 'File:01965 Biskupin, Site 1 (stronghold) - topographic map fragment (1965 system).png',
    artist: 'State Geodetic and Cartographic Service (Państwowa Służba Geodezyjna i Kartograficzna).',
    license: 'Public domain',
  ),
  'grade3/old_life': LearnImageCredit(
    asset: 'assets/images/learn/grade3/old_life.jpg',
    title: 'File:Museum display in Sapporo, Japan (25).jpg',
    artist: 'Wikimedia Commons contributor',
    license: 'CC BY-SA 4.0',
  ),
  'grade3/public_services': LearnImageCredit(
    asset: 'assets/images/learn/grade3/public_services.jpg',
    title: 'File:Tokyo Fire Department Karasuyama-1 Pumper.jpg',
    artist: 'Wikimedia Commons contributor',
    license: 'CC BY 2.0',
  ),
  'grade3/supermarket': LearnImageCredit(
    asset: 'assets/images/learn/grade3/supermarket.jpg',
    title: 'File:The produce section of a Food Lion supermarket in Clyde, North Carolina.jpg',
    artist: 'Harrison Keely',
    license: 'CC BY 4.0',
  ),
  'grade4/disaster': LearnImageCredit(
    asset: 'assets/images/learn/grade4/disaster.jpg',
    title: 'File:Camp Hansen hosts bilateral disaster-preparedness exercise 140129-M-XK110-343.jpg',
    artist: 'Cpl. Matthew Manning',
    license: 'Public domain',
  ),
  'grade4/geography': LearnImageCredit(
    asset: 'assets/images/learn/grade4/geography.jpg',
    title: 'File:Mount Fuji from Hotel Mt Fuji 1995-2-7.jpg',
    artist: 'Alpsdake',
    license: 'CC0',
  ),
  'grade4/prefectures': LearnImageCredit(
    asset: 'assets/images/learn/grade4/prefectures.jpg',
    title: 'File:Modern Japan prefectures map in 1872.jpg',
    artist: 'Yoshida Togo (1860-1932) et al',
    license: 'Public domain',
  ),
  'grade4/regions': LearnImageCredit(
    asset: 'assets/images/learn/grade4/regions.jpg',
    title: 'File:Regions and Prefectures of Japan (km).png',
    artist: 'Kiensvay',
    license: 'Public domain',
  ),
  'grade4/seasons': LearnImageCredit(
    asset: 'assets/images/learn/grade4/seasons.jpg',
    title: 'File:Cherry Blossoms and Irises, from the illustrated book Flowers of the Four Seasons (IA mma cherry blossoms and irises from the illustrated book flowers of the four se 37305).jpg',
    artist: 'Kitagawa Utamaro',
    license: 'Public domain',
  ),
  'grade4/water': LearnImageCredit(
    asset: 'assets/images/learn/grade4/water.jpg',
    title: 'File:Findlay, Ohio Water Treatment Plant.jpg',
    artist: 'Mbrickn',
    license: 'CC BY 4.0',
  ),
  'industry/agriculture': LearnImageCredit(
    asset: 'assets/images/learn/industry/agriculture.jpg',
    title: 'File:Red Rice Paddy field in Japan 003.jpg',
    artist: 'Flickr user gtknj',
    license: 'CC BY 2.0',
  ),
  'industry/fishery': LearnImageCredit(
    asset: 'assets/images/learn/industry/fishery.jpg',
    title: 'File:A harbor patrol boat from U.S. Naval Base Guam Security monitors the Japanese commercial fishing vessel Daiki Maru near the Spanish Steps Feb. 14 140214-N-TR604-002.jpg',
    artist: 'JoAnna Delfin',
    license: 'Public domain',
  ),
  'industry/food_self_sufficiency': LearnImageCredit(
    asset: 'assets/images/learn/industry/food_self_sufficiency.jpg',
    title: 'File:Fruits and vegetables displayed for sale in Spar Supermarket in Tjøme, Norway. 2018-12-16 A.jpg',
    artist: 'Wolfmann',
    license: 'CC BY-SA 4.0',
  ),
  'industry/industrial_zones': LearnImageCredit(
    asset: 'assets/images/learn/industry/industrial_zones.jpg',
    title: 'File:Laika ac Keihin Industrial Zone (7547929238).jpg',
    artist: 'Laika ac from USA',
    license: 'CC BY-SA 2.0',
  ),
  'industry/information_society': LearnImageCredit(
    asset: 'assets/images/learn/industry/information_society.jpg',
    title: 'File:BalticServers data center.jpg',
    artist: 'BalticServers.com',
    license: 'CC BY-SA 3.0',
  ),
  'industry/manufacturing': LearnImageCredit(
    asset: 'assets/images/learn/industry/manufacturing.jpg',
    title: 'File:Robotic Arm Polishing Guitars at Martin Guitar Factory.jpg',
    artist: 'Wikimedia Commons contributor',
    license: 'CC BY 4.0',
  ),
  'industry/pollution': LearnImageCredit(
    asset: 'assets/images/learn/industry/pollution.jpg',
    title: 'File:Salt Lake City smog haze skyline 01.jpg',
    artist: 'Wikimedia Commons contributor',
    license: 'CC BY-SA 4.0',
  ),
};
