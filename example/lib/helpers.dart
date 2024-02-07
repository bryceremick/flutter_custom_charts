// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';

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

const List<Color> primaryZoneColors = [
  Color(0xFF5A5A5A), // Zone 1
  Color(0xFF00B0F0), // Zone 2
  Color(0xFF00B050), // Zone 3
  Color(0xFFF6991E), // Zone 4
  Color(0xFFFF0000), // Zone 5
  Color(0xFFFF3232), // Zone 6
  Color(0xFF960096), // Zone 7
];

const secondaryOpacity = 0.75;
const List<Color> secondaryZoneColors = [
  Color.fromRGBO(90, 90, 90, secondaryOpacity), // Zone 1: 0xFF5A5A5A
  Color.fromRGBO(0, 176, 240, secondaryOpacity), // Zone 2: 0xFF00B0F0
  Color.fromRGBO(0, 176, 80, secondaryOpacity), // Zone 3: 0xFF00B050
  Color.fromRGBO(246, 153, 30, secondaryOpacity), // Zone 4: 0xFFF6991E
  Color.fromRGBO(255, 0, 0, secondaryOpacity), // Zone 5: 0xFFFF0000
  Color.fromRGBO(255, 50, 50, secondaryOpacity), // Zone 6: 0xFFFF3232
  Color.fromRGBO(150, 0, 150, secondaryOpacity), // Zone 7: 0xFF960096
];

const tertiaryOpacity = 0.35;
const List<Color> tertiaryZoneColors = [
  Color.fromRGBO(90, 90, 90, tertiaryOpacity), // Zone 1: 0xFF5A5A5A
  Color.fromRGBO(0, 176, 240, tertiaryOpacity), // Zone 2: 0xFF00B0F0
  Color.fromRGBO(0, 176, 80, tertiaryOpacity), // Zone 3: 0xFF00B050
  Color.fromRGBO(246, 153, 30, tertiaryOpacity), // Zone 4: 0xFFF6991E
  Color.fromRGBO(255, 0, 0, tertiaryOpacity), // Zone 5: 0xFFFF0000
  Color.fromRGBO(255, 50, 50, tertiaryOpacity), // Zone 6: 0xFFFF3232
  Color.fromRGBO(150, 0, 150, tertiaryOpacity), // Zone 7: 0xFF960096
];
List<double> zoneMaxes = [54, 75, 90, 105, 120, 150, 180];

Color getGradientZoneColorFromPercentage(double percentage) {
  if (percentage > 150) {
    return primaryZoneColors.last;
  }

  int zoneIndex = 0;
  for (int i = 0; i < zoneMaxes.length; i++) {
    if (percentage <= zoneMaxes[i]) {
      zoneIndex = i;
      break;
    }
  }

  double lowerBound = zoneIndex == 0 ? 0 : zoneMaxes[zoneIndex - 1];
  double upperBound = zoneMaxes[zoneIndex];
  double zoneSize = upperBound - lowerBound;
  double fraction = (percentage - lowerBound) / (upperBound - lowerBound);

  double exponent = 1 + (zoneSize / 20);
  fraction = pow(fraction, exponent).toDouble();

  Color startColor = primaryZoneColors[zoneIndex];
  Color endColor = zoneIndex < primaryZoneColors.length - 1
      ? primaryZoneColors[zoneIndex + 1]
      : primaryZoneColors[zoneIndex];
  return Color.lerp(startColor, endColor, fraction)!;
}

String twoDigits(int n) => n.toString().padLeft(2, "0");

String formatDuration(Duration duration) {
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
