// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

Random random = Random();

class BikeDataPoint {
  BikeDataPoint({
    required this.rpm,
    required this.ftp,
    required this.timestamp,
  });

  final int rpm;
  final int ftp;
  final DateTime timestamp;

  @override
  String toString() =>
      'BikeDataPoint(rpm: $rpm, ftp: $ftp, timestamp: $timestamp)';
}

class ZoneSegment {
  ZoneSegment({
    required this.start,
    required this.end,
    required this.zone,
  });
  final DateTime start;
  final DateTime end;
  final int zone;

  @override
  String toString() => 'ZoneSegment(start: $start, end: $end, zone: $zone)';
}

List<BikeDataPoint> generateBikeData(
  DateTime startTime, {
  int durationMinutes = 60,
}) {
  List<BikeDataPoint> dataPoints = [];
  int packetsPerSecond = 3;
  int totalPackets = durationMinutes * 60 * packetsPerSecond;
  Random random = Random();

  // Base and amplitude for FTP and RPM
  int ftpBase = 125, ftpAmplitude = 75;
  int rpmBase = 75, rpmAmplitude = 50;

  for (int i = 0; i < totalPackets; i++) {
    DateTime timestamp =
        startTime.add(Duration(seconds: i ~/ packetsPerSecond));

    // Generate smooth variations using sine function for FTP
    int ftp = ftpBase +
        (ftpAmplitude * sin(2 * pi * i / (1800 * packetsPerSecond))).toInt();

    // Adjust the RPM calculation to add a controlled random fluctuation
    int rpm = rpmBase +
        (rpmAmplitude * sin(2 * pi * i / (1200 * packetsPerSecond))).toInt();
    // Add a small random element to the RPM within a range of -3 to 3 to simulate variability

    // rpm += random.nextInt(5); // This will generate numbers from -3 to +3

    // Ensure ftp and rpm are within their specified ranges
    ftp = max(0, min(250, ftp));
    rpm = max(0, min(150, rpm));

    dataPoints.add(BikeDataPoint(
      rpm: rpm,
      ftp: ftp,
      timestamp: timestamp,
    ));
  }

  return dataPoints;
}

List<ZoneSegment> generateZoneSegments({
  required DateTime start,
  required DateTime end,
  required int numSegments,
}) {
  List<ZoneSegment> segments = [];
  Duration totalDuration = end.difference(start);
  Duration segmentDuration =
      totalDuration ~/ numSegments; // Integer division to distribute evenly
  Random random = Random();

  for (int i = 0; i < numSegments; i++) {
    DateTime segmentStart = start.add(segmentDuration * i);
    DateTime segmentEnd =
        i == numSegments - 1 ? end : segmentStart.add(segmentDuration);

    // Adjust the segmentEnd to start exactly after the previous segment
    if (i > 0) {
      segmentStart = segmentStart.add(Duration(milliseconds: 1));
      if (segmentStart.add(segmentDuration).isAfter(end)) {
        segmentEnd = end;
      }
    }

    int zone = random.nextInt(7) + 1; // Random zone between 1 and 7

    segments.add(
      ZoneSegment(
        start: segmentStart,
        end: segmentEnd,
        zone: zone,
      ),
    );
  }

  return segments;
}
