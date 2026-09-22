class TlCandidateDetailsModel {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? city;
  final String? state;
  final String? yearsOfExperience;
  final String? currentCtc;
  final String? expectedCtc;
  final String? noticePeriod;

  const TlCandidateDetailsModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.city,
    this.state,
    this.yearsOfExperience,
    this.currentCtc,
    this.expectedCtc,
    this.noticePeriod,
  });

  factory TlCandidateDetailsModel.fromJson(Map<String, dynamic> json) {
    return TlCandidateDetailsModel(
      userId: json['user_id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      yearsOfExperience: json['years_of_experience']?.toString(),
      currentCtc: json['current_ctc']?.toString(),
      expectedCtc: json['expected_ctc']?.toString(),
      noticePeriod: json['notice_period']?.toString(),
    );
  }
}

/// One entry from `GET /jobpost/attached-cvs/` — a CV attached to a job post,
/// shown on the Applied Candidates list.
class TlAttachedCvModel {
  final int id;
  final int candidate;
  final int postJob;
  final String name;
  final String emails;
  final String? cvFile;
  final bool? approved;
  final List<String> status;
  final String? recruiterAction;
  final bool examInviteSent;
  final String processingStatus;
  final String? failureReason;
  final String sourceType;
  final num? examScore;
  final TlCandidateDetailsModel? candidateDetails;
  // Only present when this entry came from GET .../rank-cvs/.
  final int? rank;
  final num? totalScore;

  const TlAttachedCvModel({
    required this.id,
    required this.candidate,
    required this.postJob,
    required this.name,
    required this.emails,
    this.cvFile,
    this.approved,
    required this.status,
    this.recruiterAction,
    required this.examInviteSent,
    required this.processingStatus,
    this.failureReason,
    required this.sourceType,
    this.examScore,
    this.candidateDetails,
    this.rank,
    this.totalScore,
  });

  /// `exam_score` is a plain number from /attached-cvs/ but an object
  /// (`{..., "total_score": "80.00", ...}`) from /rank-cvs/ — read whichever
  /// shape shows up.
  static num? _parseExamScore(dynamic value) {
    if (value is num) return value;
    if (value is Map) return num.tryParse(value['total_score']?.toString() ?? '');
    return null;
  }

  factory TlAttachedCvModel.fromJson(Map<String, dynamic> json) {
    return TlAttachedCvModel(
      id: json['id'] ?? 0,
      candidate: json['candidate'] ?? 0,
      postJob: json['post_job'] ?? 0,
      name: json['name'] ?? '',
      emails: json['emails'] ?? '',
      cvFile: json['cv_file'],
      approved: json['approved'],
      status: (json['status'] as List? ?? const []).map((e) => e.toString()).toList(),
      recruiterAction: json['recruiter_action']?.toString(),
      examInviteSent: json['exam_invite_sent'] ?? false,
      processingStatus: json['processing_status'] ?? '',
      failureReason: json['failure_reason'],
      sourceType: json['source_type'] ?? '',
      examScore: _parseExamScore(json['exam_score']),
      candidateDetails: json['candidate_details'] is Map<String, dynamic>
          ? TlCandidateDetailsModel.fromJson(json['candidate_details'] as Map<String, dynamic>)
          : null,
      rank: json['rank'],
      totalScore: json['total_score'],
    );
  }
}

/// Response of `GET /jobpost/post-jobs/{id}/rank-cvs/`.
class TlRankCvsResult {
  final int jobId;
  final String jobTitle;
  final num? cvCriteriaThreshold;
  final String message;
  final int totalCandidatesFound;
  final int rankedCandidatesVisible;
  final List<TlAttachedCvModel> rankedCandidates;

  const TlRankCvsResult({
    required this.jobId,
    required this.jobTitle,
    this.cvCriteriaThreshold,
    required this.message,
    required this.totalCandidatesFound,
    required this.rankedCandidatesVisible,
    required this.rankedCandidates,
  });

  factory TlRankCvsResult.fromJson(Map<String, dynamic> json) {
    return TlRankCvsResult(
      jobId: json['job_id'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      cvCriteriaThreshold: json['cv_criteria_threshold'],
      message: json['message'] ?? '',
      totalCandidatesFound: json['total_candidates_found'] ?? 0,
      rankedCandidatesVisible: json['ranked_candidates_visible'] ?? 0,
      rankedCandidates: (json['ranked_candidates'] as List? ?? const [])
          .map((e) => TlAttachedCvModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
