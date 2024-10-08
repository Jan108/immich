//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserPreferencesUpdateDto {
  /// Returns a new [UserPreferencesUpdateDto] instance.
  UserPreferencesUpdateDto({
    this.avatar,
    this.download,
    this.emailNotifications,
    this.memories,
    this.purchase,
    this.rating,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  AvatarUpdate? avatar;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DownloadUpdate? download;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  EmailNotificationsUpdate? emailNotifications;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  MemoryUpdate? memories;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PurchaseUpdate? purchase;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  RatingUpdate? rating;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserPreferencesUpdateDto &&
    other.avatar == avatar &&
    other.download == download &&
    other.emailNotifications == emailNotifications &&
    other.memories == memories &&
    other.purchase == purchase &&
    other.rating == rating;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (avatar == null ? 0 : avatar!.hashCode) +
    (download == null ? 0 : download!.hashCode) +
    (emailNotifications == null ? 0 : emailNotifications!.hashCode) +
    (memories == null ? 0 : memories!.hashCode) +
    (purchase == null ? 0 : purchase!.hashCode) +
    (rating == null ? 0 : rating!.hashCode);

  @override
  String toString() => 'UserPreferencesUpdateDto[avatar=$avatar, download=$download, emailNotifications=$emailNotifications, memories=$memories, purchase=$purchase, rating=$rating]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.avatar != null) {
      json[r'avatar'] = this.avatar;
    } else {
    //  json[r'avatar'] = null;
    }
    if (this.download != null) {
      json[r'download'] = this.download;
    } else {
    //  json[r'download'] = null;
    }
    if (this.emailNotifications != null) {
      json[r'emailNotifications'] = this.emailNotifications;
    } else {
    //  json[r'emailNotifications'] = null;
    }
    if (this.memories != null) {
      json[r'memories'] = this.memories;
    } else {
    //  json[r'memories'] = null;
    }
    if (this.purchase != null) {
      json[r'purchase'] = this.purchase;
    } else {
    //  json[r'purchase'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
    //  json[r'rating'] = null;
    }
    return json;
  }

  /// Returns a new [UserPreferencesUpdateDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserPreferencesUpdateDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return UserPreferencesUpdateDto(
        avatar: AvatarUpdate.fromJson(json[r'avatar']),
        download: DownloadUpdate.fromJson(json[r'download']),
        emailNotifications: EmailNotificationsUpdate.fromJson(json[r'emailNotifications']),
        memories: MemoryUpdate.fromJson(json[r'memories']),
        purchase: PurchaseUpdate.fromJson(json[r'purchase']),
        rating: RatingUpdate.fromJson(json[r'rating']),
      );
    }
    return null;
  }

  static List<UserPreferencesUpdateDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserPreferencesUpdateDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserPreferencesUpdateDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserPreferencesUpdateDto> mapFromJson(dynamic json) {
    final map = <String, UserPreferencesUpdateDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserPreferencesUpdateDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserPreferencesUpdateDto-objects as value to a dart map
  static Map<String, List<UserPreferencesUpdateDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserPreferencesUpdateDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserPreferencesUpdateDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

