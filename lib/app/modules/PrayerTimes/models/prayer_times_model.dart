class PrayerTimesResponse {
  final int code;
  final String status;
  final List<PrayerData> data;

  PrayerTimesResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimesResponse(
      code: json['code'],
      status: json['status'],
      data: (json['data'] as List).map((i) => PrayerData.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'data': data.map((i) => i.toJson()).toList(),
    };
  }
}

class PrayerData {
  final Timings timings;
  final DateModel date;
  final Meta meta;

  PrayerData({
    required this.timings,
    required this.date,
    required this.meta,
  });

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: Timings.fromJson(json['timings']),
      date: DateModel.fromJson(json['date']),
      meta: Meta.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timings': timings.toJson(),
      'date': date.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'],
      sunrise: json['Sunrise'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      sunset: json['Sunset'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
      imsak: json['Imsak'],
      midnight: json['Midnight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Sunset': sunset,
      'Maghrib': maghrib,
      'Isha': isha,
      'Imsak': imsak,
      'Midnight': midnight,
    };
  }
}

class DateModel {
  final String readable;
  final String timestamp;
  final HijriDate hijri;
  final GregorianDate gregorian;

  DateModel({
    required this.readable,
    required this.timestamp,
    required this.hijri,
    required this.gregorian,
  });

  factory DateModel.fromJson(Map<String, dynamic> json) {
    return DateModel(
      readable: json['readable'],
      timestamp: json['timestamp'],
      hijri: HijriDate.fromJson(json['hijri']),
      gregorian: GregorianDate.fromJson(json['gregorian']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'readable': readable,
      'timestamp': timestamp,
      'hijri': hijri.toJson(),
      'gregorian': gregorian.toJson(),
    };
  }
}

class HijriDate {
  final String date;
  final String day;
  final HijriWeekday weekday;
  final HijriMonth month;
  final String year;

  HijriDate({
    required this.date,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'],
      day: json['day'],
      weekday: HijriWeekday.fromJson(json['weekday']),
      month: HijriMonth.fromJson(json['month']),
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'weekday': weekday.toJson(),
      'month': month.toJson(),
      'year': year,
    };
  }
}

class HijriWeekday {
  final String en;
  final String ar;

  HijriWeekday({required this.en, required this.ar});

  factory HijriWeekday.fromJson(Map<String, dynamic> json) {
    return HijriWeekday(en: json['en'], ar: json['ar']);
  }

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};
}

class HijriMonth {
  final int number;
  final String en;
  final String ar;

  HijriMonth({required this.number, required this.en, required this.ar});

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'],
      en: json['en'],
      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() => {'number': number, 'en': en, 'ar': ar};
}

class GregorianDate {
  final String date;
  final String day;
  final GregorianWeekday weekday;
  final GregorianMonth month;
  final String year;

  GregorianDate({
    required this.date,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'],
      day: json['day'],
      weekday: GregorianWeekday.fromJson(json['weekday']),
      month: GregorianMonth.fromJson(json['month']),
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'weekday': weekday.toJson(),
      'month': month.toJson(),
      'year': year,
    };
  }
}

class GregorianWeekday {
  final String en;
  GregorianWeekday({required this.en});
  factory GregorianWeekday.fromJson(Map<String, dynamic> json) => GregorianWeekday(en: json['en']);
  Map<String, dynamic> toJson() => {'en': en};
}

class GregorianMonth {
  final int number;
  final String en;
  GregorianMonth({required this.number, required this.en});
  factory GregorianMonth.fromJson(Map<String, dynamic> json) => GregorianMonth(number: json['number'], en: json['en']);
  Map<String, dynamic> toJson() => {'number': number, 'en': en};
}

class Meta {
  final double latitude;
  final double longitude;
  final String timezone;
  final Method method;

  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.method,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timezone: json['timezone'],
      method: Method.fromJson(json['method']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'method': method.toJson(),
    };
  }
}

class Method {
  final int id;
  final String name;

  Method({required this.id, required this.name});

  factory Method.fromJson(Map<String, dynamic> json) {
    return Method(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
