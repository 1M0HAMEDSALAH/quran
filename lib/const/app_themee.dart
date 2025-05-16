import 'package:flutter/material.dart';

// Light Theme
ThemeData theme() {
  return ThemeData(
    fontFamily: 'BahijTheSansArabic', // Base font family for the entire app
    primaryColor: const Color(0xFFF35F16),
    scaffoldBackgroundColor: const Color(0xFFF3F3F3),
    appBarTheme: appBarTheme(),
    radioTheme: radioTheme(),
    dialogTheme: dialogTheme(),
    textButtonTheme: textButtonTheme(),
    bottomSheetTheme: bottomSheetTheme(),
    dropdownMenuTheme: dropdownMenuTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    // Add text theme to ensure consistent font styling
    textTheme: createTextTheme(Colors.black),
    // Ensure buttons use the font family
    buttonTheme: buttonTheme(),
    // Add other theme elements that may contain text
    snackBarTheme: snackBarTheme(),
    tabBarTheme: tabBarTheme(),
    tooltipTheme: tooltipTheme(),
    cardTheme: cardTheme(),
    chipTheme: chipTheme(),
    listTileTheme: listTileTheme(),
  );
}

// Dark Theme
ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: const Color(0xFFF35F16),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: appBarTheme().copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'BahijTheSansArabic',
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
    ),
    radioTheme: radioTheme(),
    dialogTheme: dialogTheme().copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    textButtonTheme: textButtonTheme(),
    bottomSheetTheme: bottomSheetTheme().copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
      modalBackgroundColor: const Color(0xFF121212),
    ),
    dropdownMenuTheme: darkDropdownMenuTheme(),
    inputDecorationTheme: inputDecorationTheme().copyWith(
      fillColor: const Color(0xFF2C2C2C),
      labelStyle: const TextStyle(
          color: Colors.white70, fontFamily: 'BahijTheSansArabic'),
    ),
    // Add text theme with light colors for dark mode
    textTheme: createTextTheme(Colors.white),
    // Ensure buttons use the font family
    buttonTheme: buttonTheme(),
    // Add other dark theme elements that may contain text
    snackBarTheme: snackBarTheme().copyWith(
      backgroundColor: const Color(0xFF2C2C2C),
      contentTextStyle: const TextStyle(
          color: Colors.white, fontFamily: 'BahijTheSansArabic'),
    ),
    tabBarTheme: tabBarTheme().copyWith(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
    ),
    tooltipTheme: tooltipTheme().copyWith(
      textStyle: const TextStyle(
          color: Colors.black, fontFamily: 'BahijTheSansArabic'),
    ),
    cardTheme: cardTheme().copyWith(
      color: const Color(0xFF2C2C2C),
    ),
    chipTheme: chipTheme().copyWith(
      backgroundColor: const Color(0xFF3C3C3C),
      labelStyle: const TextStyle(
          color: Colors.white, fontFamily: 'BahijTheSansArabic'),
    ),
    listTileTheme: listTileTheme().copyWith(
      textColor: Colors.white,
      iconColor: Colors.white70,
    ),
  );
}

// Helper method to create a consistent TextTheme with the font applied
TextTheme createTextTheme(Color textColor) {
  return TextTheme(
    displayLarge: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold),
    displaySmall: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600),
    titleLarge: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600),
    titleSmall: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(
        fontFamily: 'BahijTheSansArabic', color: textColor, fontSize: 16),
    bodyMedium: TextStyle(
        fontFamily: 'BahijTheSansArabic', color: textColor, fontSize: 14),
    bodySmall: TextStyle(
        fontFamily: 'BahijTheSansArabic', color: textColor, fontSize: 12),
    labelLarge: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500),
    labelMedium: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
        fontFamily: 'BahijTheSansArabic',
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w500),
  );
}

InputDecorationTheme inputDecorationTheme() {
  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(width: 1, color: Color(0xFFDCD5D5)),
      borderRadius: BorderRadius.circular(8),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(width: 1, color: Color(0xFFDCD5D5)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(width: 2, color: Colors.black12),
      borderRadius: BorderRadius.circular(8),
    ),
    border: OutlineInputBorder(
      borderSide:
          const BorderSide(width: 1, color: Color.fromARGB(255, 245, 125, 32)),
      borderRadius: BorderRadius.circular(8),
    ),
    labelStyle: const TextStyle(
        color: Colors.black45,
        fontFamily: 'BahijTheSansArabic'), // Add font to label style
    hintStyle: const TextStyle(
        fontFamily: 'BahijTheSansArabic'), // Add hint style with font
    errorStyle: const TextStyle(
        fontFamily: 'BahijTheSansArabic'), // Add error style with font
  );
}

TextButtonThemeData textButtonTheme() {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(Color(0xFFF35F16)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontFamily: 'BahijTheSansArabic'), // Add font to text buttons
      ),
    ),
  );
}

DialogTheme dialogTheme() {
  return DialogTheme(
    backgroundColor: const Color(0xFFF3F3F3),
    titleTextStyle: const TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 14,
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 4.0,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black26,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontFamily: 'BahijTheSansArabic',
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    toolbarTextStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic', // Add font to toolbar text
    ),
  );
}

BottomSheetThemeData bottomSheetTheme() {
  return const BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 10.0,
    modalBackgroundColor: Color(0xFFF3F3F3),
    modalElevation: 10.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(8),
      ),
    ),
    dragHandleColor: Color(0xFFDCD5D5),
    dragHandleSize: Size(40, 4),
  );
}

DropdownMenuThemeData dropdownMenuTheme() {
  return DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: const MaterialStatePropertyAll(Colors.white),
      elevation: const MaterialStatePropertyAll(4.0),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(width: 1, color: Color(0xFFDCD5D5)),
        ),
      ),
      padding:
          const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 8.0)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Color(0xFFDCD5D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 2, color: Color(0xFFF35F16)),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: const TextStyle(fontFamily: 'BahijTheSansArabic'), // Add font
    ),
    textStyle: const TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 12,
      color: Colors.black,
    ),
  );
}

DropdownMenuThemeData darkDropdownMenuTheme() {
  return DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: const MaterialStatePropertyAll(Color(0xFF2C2C2C)),
      elevation: const MaterialStatePropertyAll(4.0),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(width: 1, color: Color(0xFF3C3C3C)),
        ),
      ),
      padding:
          const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 8.0)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Color(0xFF3C3C3C)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 2, color: Color(0xFFF35F16)),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: const TextStyle(
          fontFamily: 'BahijTheSansArabic', color: Colors.white70),
    ),
    textStyle: const TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 12,
      color: Colors.white,
    ),
  );
}

ButtonThemeData buttonTheme() {
  return ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(width: 1, color: Color(0xFFDCD5D5)),
    ),
    buttonColor: Colors.white,
    disabledColor: Colors.grey.shade200,
    alignedDropdown: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFF35F16),
    ),
    textTheme: ButtonTextTheme.primary, // Ensure button text uses theme
  );
}

RadioThemeData radioTheme() {
  return const RadioThemeData(
    fillColor: WidgetStatePropertyAll(Color(0xFFF35F16)),
  );
}

// Add more theme components to ensure font consistency
SnackBarThemeData snackBarTheme() {
  return const SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    contentTextStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
      color: Colors.white,
    ),
    actionTextColor: Color(0xFFF35F16),
  );
}

TabBarTheme tabBarTheme() {
  return const TabBarTheme(
    labelStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
    ),
    labelColor: Color(0xFFF35F16),
    unselectedLabelColor: Colors.black54,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        width: 2.0,
        color: Color(0xFFF35F16),
      ),
    ),
  );
}

TooltipThemeData tooltipTheme() {
  return TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: const TextStyle(
      fontFamily: 'BahijTheSansArabic',
      color: Colors.black,
      fontSize: 12,
    ),
  );
}

CardTheme cardTheme() {
  return CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    clipBehavior: Clip.antiAlias,
  );
}

ChipThemeData chipTheme() {
  return const ChipThemeData(
    backgroundColor: Color(0xFFE0E0E0),
    labelStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
    ),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  );
}

ListTileThemeData listTileTheme() {
  return const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    titleTextStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    subtitleTextStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 12,
      color: Colors.black54,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontFamily: 'BahijTheSansArabic',
      fontSize: 12,
    ),
  );
}
