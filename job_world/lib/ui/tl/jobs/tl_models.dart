import 'package:flutter/material.dart';

/// Lightweight mock models for the TL (Team Lead) job & candidate flow.
/// These are placeholders until a real Job/Candidate API + repository exists.

class TlJobModel {
  final String id;
  final String reqId;
  final String title;
  final String location;
  final String experience;
  final int openings;
  final String salary;
  final String employmentType;
  final String status; // Open, Closed
  final String company;
  final List<String> locations;
  final String description;
  final List<String> skills;
  final int appliedCount;
  final int walkInCount;

  const TlJobModel({
    required this.id,
    required this.reqId,
    required this.title,
    required this.location,
    required this.experience,
    required this.openings,
    required this.salary,
    required this.employmentType,
    required this.status,
    required this.company,
    required this.locations,
    required this.description,
    required this.skills,
    required this.appliedCount,
    required this.walkInCount,
  });
}

/// A user returned by `GET /user/users/?context=jobpost_assign`, used to
/// populate the "Assigned Recruiter" dropdown on the Post Job wizard.
class TlJobAssignUserModel {
  final int id;
  final String username;
  final String roleName;

  const TlJobAssignUserModel({
    required this.id,
    required this.username,
    required this.roleName,
  });

  factory TlJobAssignUserModel.fromJson(Map<String, dynamic> json) {
    return TlJobAssignUserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      roleName: json['role_name'] ?? '',
    );
  }
}

/// One entry from `GET /jobpost/jobs/{id}/approval-history/` — a stage
/// transition in the job post's approval workflow.
class TlJobApprovalHistoryEntry {
  final String by;
  final String to;
  final String from;
  final String time;
  final String event;
  final String byRole;
  final String? comment;
  final String? departmentName;
  final bool? isOverride;

  const TlJobApprovalHistoryEntry({
    required this.by,
    required this.to,
    required this.from,
    required this.time,
    required this.event,
    required this.byRole,
    this.comment,
    this.departmentName,
    this.isOverride,
  });

  factory TlJobApprovalHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TlJobApprovalHistoryEntry(
      by: json['by'] ?? '',
      to: json['to'] ?? '',
      from: json['from'] ?? '',
      time: json['time'] ?? '',
      event: json['event'] ?? '',
      byRole: json['by_role'] ?? '',
      comment: json['comment'],
      departmentName: json['department_name'],
      isOverride: json['is_override'],
    );
  }
}

class TlJobApprovalHistoryModel {
  final List<TlJobApprovalHistoryEntry> history;
  final String currentStage;

  const TlJobApprovalHistoryModel({required this.history, required this.currentStage});

  factory TlJobApprovalHistoryModel.fromJson(Map<String, dynamic> json) {
    return TlJobApprovalHistoryModel(
      history: (json['history'] as List? ?? const [])
          .map((e) => TlJobApprovalHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStage: json['current_stage'] ?? '',
    );
  }
}

class TlCandidateModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String initial;
  final Color avatarColor;
  final List<String> statusTags; // e.g. ["Done", "Approved", "Pending"] or ["In Review"]
  final double? score;
  final String selectStatus; // "Select Status", "In progress", "Selected", "Rejected", "On Hold"
  final String source; // "Applied" or "Walk-in"

  const TlCandidateModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.initial,
    required this.avatarColor,
    required this.statusTags,
    this.score,
    this.selectStatus = "Select Status",
    required this.source,
  });

  TlCandidateModel copyWith({String? selectStatus}) {
    return TlCandidateModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      initial: initial,
      avatarColor: avatarColor,
      statusTags: statusTags,
      score: score,
      selectStatus: selectStatus ?? this.selectStatus,
      source: source,
    );
  }
}
