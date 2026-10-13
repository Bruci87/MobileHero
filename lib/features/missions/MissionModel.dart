import 'package:equatable/equatable.dart';

class MissionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final int requiredPower;
  final int rewardXp;
  final int durationMinutes;
  final bool isCompleted;
  final bool isInProgress;
  final int? startTimeMillis;
  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPower,
    required this.rewardXp,
    required this.durationMinutes,
    this.isCompleted = false,
    this.isInProgress = false,
    this.startTimeMillis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredPower': requiredPower,
      'rewardXp': rewardXp,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted ? 1 : 0,
      'isInProgress': isInProgress ? 1 : 0,
      'startTimeMillis': startTimeMillis,
    };
  }

  factory MissionModel.fromJson(Map<String, dynamic> map) {
    return MissionModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      requiredPower: map['requiredPower'] is int ? map['requiredPower'] : int.parse(map['requiredPower'].toString()),
      rewardXp: map['rewardXp'] is int ? map['rewardXp'] : int.parse(map['rewardXp'].toString()),
      durationMinutes: map['durationMinutes'] is int ? map['durationMinutes'] : int.parse(map['durationMinutes'].toString()),
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      isInProgress: map['isInProgress'] == 1 || map['isInProgress'] == true,
      startTimeMillis: map['startTimeMillis'] != null ? int.parse(map['startTimeMillis'].toString()) : null,
    );
  }

  MissionModel copyWith({
    bool? isCompleted,
    bool? isInProgress,
    int? startTimeMillis,
  }) {
    return MissionModel(
      id: id,
      title: title,
      description: description,
      requiredPower: requiredPower,
      rewardXp: rewardXp,
      durationMinutes: durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isInProgress: isInProgress ?? this.isInProgress,
      startTimeMillis: startTimeMillis ?? this.startTimeMillis,
    );
  }

  @override
  List<Object?> get props => [id, title, description, requiredPower, rewardXp, durationMinutes, isCompleted, isInProgress, startTimeMillis];
}