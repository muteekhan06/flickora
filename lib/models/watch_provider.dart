import '../core/constants.dart';

class WatchProvider {
  final int id;
  final String name;
  final String? logoPath;
  final String type; // 'Stream Free', 'Subscription', 'Rent / Buy'

  WatchProvider({
    required this.id,
    required this.name,
    this.logoPath,
    required this.type,
  });

  String get logoUrl {
    if (logoPath == null || logoPath!.isEmpty) {
      return 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?w=200&auto=format&fit=crop&q=80';
    }
    return '${FlickoraConstants.imageBaseW500}$logoPath';
  }

  factory WatchProvider.fromJson(Map<String, dynamic> json, {String type = 'Subscription'}) {
    return WatchProvider(
      id: json['provider_id'] ?? 0,
      name: json['provider_name'] ?? 'Streaming Provider',
      logoPath: json['logo_path'],
      type: type,
    );
  }
}
