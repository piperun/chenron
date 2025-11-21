import "package:flutter/material.dart";

const kBreakpointSmall = 479.0;
const kBreakpointMedium = 767.0;
const kBreakpointLarge = 991.0;
bool isMobileWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kBreakpointSmall;
bool responsiveVisibility({
  required BuildContext context,
  bool phone = true,
  bool tablet = true,
  bool tabletLandscape = true,
  bool desktop = true,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kBreakpointSmall) {
    return phone;
  } else if (width < kBreakpointMedium) {
    return tablet;
  } else if (width < kBreakpointLarge) {
    return tabletLandscape;
  } else {
    return desktop;
  }
}

class Breakpoints {
  // Define breakpoints similar to Tailwind CSS
  static const double xs =
      0; // Extra small devices (portrait phones, less than 576px)
  static const double sm =
      576; // Small devices (landscape phones, 576px and up)
  static const double md = 768; // Medium devices (tablets, 768px and up)
  static const double lg = 992; // Large devices (desktops, 992px and up)
  static const double xl =
      1200; // Extra large devices (large desktops, 1200px and up)

  // Utility functions with Tailwind-like ratios
  static double responsiveWidth(BuildContext context,
      {double ratioSm = 1.0,
      double ratioMd = 0.875,
      double ratioLg = 0.75,
      double ratioXl = 0.625}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= sm) {
      return screenWidth * ratioSm;
    } else if (screenWidth <= md) {
      return screenWidth * ratioMd;
    } else if (screenWidth <= lg) {
      return screenWidth * ratioLg;
    } else if (screenWidth <= xl) {
      return screenWidth * ratioXl;
    } else {
      return screenWidth * 0.375; // Default for extra large screens
    }
  }

  static double responsiveHeight(BuildContext context,
      {double ratioSm = 1.0,
      double ratioMd = 0.875,
      double ratioLg = 0.75,
      double ratioXl = 0.625}) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= sm) {
      return screenHeight * ratioSm;
    } else if (screenHeight <= md) {
      return screenHeight * ratioMd;
    } else if (screenHeight <= lg) {
      return screenHeight * ratioLg;
    } else if (screenHeight <= xl) {
      return screenHeight * ratioXl;
    } else {
      return screenHeight * 0.375; // Default for extra large screens
    }
  }

  static bool isExtraSmall(BuildContext context) =>
      MediaQuery.of(context).size.width > xs;
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width > sm;
  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width > md;
  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width > lg;
  static bool isExtraLarge(BuildContext context) =>
      MediaQuery.of(context).size.width > xl;
}
