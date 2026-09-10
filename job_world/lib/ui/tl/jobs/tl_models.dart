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

// ---------------------------------------------------------------------------
// MOCK DATA
// ---------------------------------------------------------------------------

const List<TlJobModel> mockTlJobs = [
  TlJobModel(
    id: 'j1',
    reqId: 'REQ-2024-090',
    title: 'iOS Developer',
    location: 'Mumbai',
    experience: '0-2 Years',
    openings: 2,
    salary: '₹500,000',
    employmentType: 'Full Time',
    status: 'Open',
    company: 'ORBIT TECHSOL PVT LTD',
    locations: ['Mumbai', 'Navi Mumbai', 'Pune'],
    description:
        "We are looking for an iOS Developer who possesses a passion for pushing mobile technologies to the limits. You will work with our team of talented engineers to design and build the next generation of our mobile applications. Expertise in Swift, SwiftUI, and general iOS Development is required.",
    skills: ['Swift', 'SwiftUI', 'iOS SDK', 'Core Data'],
    appliedCount: 24,
    walkInCount: 150,
  ),
  TlJobModel(
    id: 'j2',
    reqId: 'REQ-2024-081',
    title: 'Junior Python Developer',
    location: 'Pune',
    experience: '0-2 Yrs',
    openings: 1,
    salary: '₹65,000',
    employmentType: 'Full Time',
    status: 'Open',
    company: 'ORBIT TECHSOL PVT LTD',
    locations: ['Pune'],
    description:
        "We are looking for a Junior Python Developer to join our engineering team, working on backend services and internal automation tooling under senior mentorship.",
    skills: ['Python', 'Django', 'SQL'],
    appliedCount: 12,
    walkInCount: 80,
  ),
  TlJobModel(
    id: 'j3',
    reqId: 'REQ-2024-082',
    title: 'Node.js Developer',
    location: 'Pune',
    experience: '0-3 Yrs',
    openings: 2,
    salary: '₹1,10,000',
    employmentType: 'Full Time',
    status: 'Open',
    company: 'ORBIT TECHSOL PVT LTD',
    locations: ['Pune'],
    description:
        "We are looking for a Node.js Developer to build and maintain scalable REST APIs and microservices powering our core platform.",
    skills: ['Node.js', 'Express', 'MongoDB'],
    appliedCount: 18,
    walkInCount: 60,
  ),
  TlJobModel(
    id: 'j4',
    reqId: 'REQ-2024-068',
    title: 'Data Analyst',
    location: 'Hyderabad',
    experience: '1-3 Yrs',
    openings: 1,
    salary: '₹90,000',
    employmentType: 'Full Time',
    status: 'Closed',
    company: 'ORBIT TECHSOL PVT LTD',
    locations: ['Hyderabad'],
    description:
        "We are looking for a Data Analyst to turn raw hiring & business data into actionable dashboards and reports for leadership.",
    skills: ['SQL', 'Excel', 'Power BI'],
    appliedCount: 9,
    walkInCount: 20,
  ),
];

List<TlCandidateModel> mockAppliedCandidates(String jobId) => const [
      TlCandidateModel(
        id: 'a1',
        name: 'Ajinkya',
        email: 'Ajjinkya@example.com',
        phone: '91456587980',
        initial: 'A',
        avatarColor: Color(0xFF6366F1),
        statusTags: ['Done', 'Approved', 'Pending'],
        score: 67.82,
        source: 'Applied',
      ),
      TlCandidateModel(
        id: 'a2',
        name: 'Radhika Chandak',
        email: 'Radha78@example.com',
        phone: '91456587980',
        initial: 'R',
        avatarColor: Color(0xFF6366F1),
        statusTags: ['Done', 'Approved', 'Pending'],
        score: 67.82,
        source: 'Applied',
      ),
      TlCandidateModel(
        id: 'a3',
        name: 'Akshay Jadhav',
        email: 'akshay@example.com',
        initial: 'A',
        avatarColor: Color(0xFF6366F1),
        statusTags: ['In Review'],
        source: 'Applied',
      ),
      TlCandidateModel(
        id: 'a4',
        name: 'Shreya Desai',
        email: 'shreya@example.com',
        phone: '91456587980',
        initial: 'S',
        avatarColor: Color(0xFF10B981),
        statusTags: ['In Review'],
        source: 'Applied',
      ),
    ];

List<TlCandidateModel> mockWalkInCandidates(String jobId) => const [
      TlCandidateModel(
        id: 'w1',
        name: 'Ajinkya',
        email: 'Ajjinkya@example.com',
        phone: '91456587980',
        initial: 'A',
        avatarColor: Color(0xFF6366F1),
        statusTags: ['Done', 'Approved', 'Pending'],
        score: 67.82,
        source: 'Walk-in',
      ),
      TlCandidateModel(
        id: 'w2',
        name: 'Radhika Chandak',
        email: 'Radha78@example.com',
        phone: '91456587980',
        initial: 'R',
        avatarColor: Color(0xFF6366F1),
        statusTags: ['Done', 'Approved', 'Pending'],
        score: 67.82,
        source: 'Walk-in',
      ),
      TlCandidateModel(
        id: 'w3',
        name: 'Radhika Chandak',
        email: 'Radha78@example.com',
        phone: '91456587980',
        initial: 'R',
        avatarColor: Color(0xFF6366F1),
        statusTags: ['Done', 'Approved', 'Pending'],
        score: 67.82,
        source: 'Walk-in',
      ),
    ];
