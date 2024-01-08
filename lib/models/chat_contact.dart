import 'package:flutter/foundation.dart';

class ChatContact {
  final String id;
  final String name;
  final String profilePic;
  final List<String> contacts;

  ChatContact({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.contacts,
  });

  ChatContact copyWith({
    String? id,
    String? name,
    String? profilePic,
    List<String>? contacts,
  }) {
    return ChatContact(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      contacts: contacts ?? this.contacts,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'profilePic': profilePic,
      'contacts': contacts,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      id: map['id'] as String,
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      contacts: List<String>.from(map['contacts']),
    );
  }

  @override
  String toString() => 'ChatContact(id: $id, name: $name, profilePic: $profilePic, contacts: $contacts)';

  @override
  bool operator ==(covariant ChatContact other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.profilePic == profilePic &&
      listEquals(other.contacts, contacts);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ profilePic.hashCode ^ contacts.hashCode;
}
