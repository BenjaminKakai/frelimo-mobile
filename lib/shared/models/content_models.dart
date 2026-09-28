/// Lightweight DTOs for news, voting, surveys, reports, broadcasts, audit,
/// donations. Each uses tolerant `?.toString()` parsing because the Mozambique
/// backend has historically returned loose types (numbers as strings, mixed
/// casing on enums). Never use `as String` here.

class Article {
  final String id;
  final String slug;
  final String title;
  final String? excerpt;
  final String? body;
  final String? coverUrl;
  final String? category;
  final DateTime? publishedAt;
  const Article({
    required this.id,
    required this.slug,
    required this.title,
    this.excerpt,
    this.body,
    this.coverUrl,
    this.category,
    this.publishedAt,
  });
  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: j['id']?.toString() ?? '',
        slug: j['slug']?.toString() ?? j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        excerpt: j['excerpt']?.toString() ?? j['summary']?.toString(),
        body: j['body']?.toString() ?? j['content']?.toString(),
        coverUrl: j['coverUrl']?.toString() ??
            j['cover']?.toString() ??
            j['imageUrl']?.toString(),
        category: j['category']?.toString(),
        publishedAt: DateTime.tryParse(
            j['publishedAt']?.toString() ?? j['createdAt']?.toString() ?? ''),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'title': title,
        'excerpt': excerpt,
        'body': body,
        'coverUrl': coverUrl,
        'category': category,
        'publishedAt': publishedAt?.toIso8601String(),
      };
}

class Candidate {
  final String id;
  final String name;
  final String? statement;
  final String? photoUrl;
  final int votes;
  const Candidate({
    required this.id,
    required this.name,
    this.statement,
    this.photoUrl,
    this.votes = 0,
  });
  factory Candidate.fromJson(Map<String, dynamic> j) {
    final joined = [j['firstName'], j['lastName']]
        .where((s) => s != null && s.toString().isNotEmpty)
        .join(' ');
    // `GET /elections/:id/candidates` returns only { id, memberId, position },
    // with no name on the row, so fall back to the position and finally the
    // member number. A ballot line must never render blank.
    final name = (j['name']?.toString().trim().isNotEmpty ?? false)
        ? j['name'].toString()
        : joined.isNotEmpty
            ? joined
            : (j['position']?.toString() ??
                j['memberNumber']?.toString() ??
                '');
    return Candidate(
      id: j['id']?.toString() ?? '',
      name: name,
      statement: j['statement']?.toString() ?? j['bio']?.toString(),
      photoUrl: j['photoUrl']?.toString() ?? j['avatarUrl']?.toString(),
      votes: (j['votes'] as num?)?.toInt() ?? 0,
    );
  }
}

class Election {
  final String id;
  final String title;
  final String? description;
  final String? scope;
  final String status; // OPEN | UPCOMING | CLOSED | DRAFT
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool hasVoted;
  final List<Candidate> candidates;
  const Election({
    required this.id,
    required this.title,
    this.description,
    this.scope,
    this.status = 'DRAFT',
    this.startsAt,
    this.endsAt,
    this.hasVoted = false,
    this.candidates = const [],
  });
  factory Election.fromJson(Map<String, dynamic> j) {
    final raw = j['candidates'];
    final cands = raw is List
        ? raw
            .map((e) => Candidate.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <Candidate>[];
    return Election(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString(),
      scope: j['scope']?.toString(),
      status: (j['status']?.toString() ?? 'DRAFT').toUpperCase(),
      startsAt: DateTime.tryParse(j['startsAt']?.toString() ?? ''),
      endsAt: DateTime.tryParse(j['endsAt']?.toString() ?? ''),
      hasVoted: j['hasVoted'] as bool? ?? false,
      candidates: cands,
    );
  }
}

class SurveyQuestion {
  final String id;
  final String prompt;
  final String type; // TEXT | MULTIPLE_CHOICE | SCALE | BOOLEAN
  final List<String> options;
  final int? min;
  final int? max;
  const SurveyQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    this.options = const [],
    this.min,
    this.max,
  });
  factory SurveyQuestion.fromJson(Map<String, dynamic> j) {
    final opts = j['options'];
    final list = opts is List
        ? opts.map((e) => e.toString()).toList()
        : <String>[];
    return SurveyQuestion(
      id: j['id']?.toString() ?? '',
      prompt: j['prompt']?.toString() ?? j['question']?.toString() ?? '',
      type: (j['type']?.toString() ?? 'TEXT').toUpperCase(),
      options: list,
      min: (j['min'] as num?)?.toInt(),
      max: (j['max'] as num?)?.toInt(),
    );
  }
}

class Survey {
  final String id;
  final String title;
  final String? description;
  final String status;
  final bool answered;
  final DateTime? closesAt;
  final List<SurveyQuestion> questions;
  const Survey({
    required this.id,
    required this.title,
    this.description,
    this.status = 'OPEN',
    this.answered = false,
    this.closesAt,
    this.questions = const [],
  });
  factory Survey.fromJson(Map<String, dynamic> j) {
    final raw = j['questions'];
    final qs = raw is List
        ? raw
            .map((e) =>
                SurveyQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <SurveyQuestion>[];
    return Survey(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString(),
      status: (j['status']?.toString() ?? 'OPEN').toUpperCase(),
      answered: j['answered'] as bool? ?? false,
      // The Survey row calls the closing date `endsAt`; keep reading
      // `closesAt` too in case a future endpoint renames it.
      closesAt: DateTime.tryParse(
          (j['closesAt'] ?? j['endsAt'])?.toString() ?? ''),
      questions: qs,
    );
  }
}

class Broadcast {
  final String id;
  final String channel;
  final String subject;
  final String? body;
  final int sentCount;
  final DateTime? sentAt;
  const Broadcast({
    required this.id,
    required this.channel,
    required this.subject,
    this.body,
    this.sentCount = 0,
    this.sentAt,
  });
  factory Broadcast.fromJson(Map<String, dynamic> j) => Broadcast(
        id: j['id']?.toString() ?? '',
        channel: (j['channel']?.toString() ?? 'IN_APP').toUpperCase(),
        subject: j['subject']?.toString() ?? '',
        body: j['body']?.toString(),
        sentCount: (j['sentCount'] as num?)?.toInt() ??
            (j['recipientCount'] as num?)?.toInt() ??
            0,
        sentAt: DateTime.tryParse(
            j['sentAt']?.toString() ?? j['createdAt']?.toString() ?? ''),
      );
}

class AuditEvent {
  final String id;
  final DateTime? at;
  final String actor;
  final String action;
  final String? target;
  final String? ip;
  const AuditEvent({
    required this.id,
    this.at,
    required this.actor,
    required this.action,
    this.target,
    this.ip,
  });
  factory AuditEvent.fromJson(Map<String, dynamic> j) => AuditEvent(
        id: j['id']?.toString() ?? '',
        at: DateTime.tryParse(
            j['at']?.toString() ?? j['createdAt']?.toString() ?? ''),
        actor: j['actor']?.toString() ??
            j['actorEmail']?.toString() ??
            j['userId']?.toString() ??
            '—',
        action: j['action']?.toString() ?? '',
        target: j['target']?.toString() ?? j['resource']?.toString(),
        ip: j['ip']?.toString() ?? j['ipAddress']?.toString(),
      );
}

class Donation {
  final String id;
  final double amount;
  final String currency;
  final String channel;
  final String? donorName;
  final String? memberNumber;
  final DateTime? receivedAt;
  const Donation({
    required this.id,
    required this.amount,
    this.currency = 'MZN',
    this.channel = 'CASH',
    this.donorName,
    this.memberNumber,
    this.receivedAt,
  });
  factory Donation.fromJson(Map<String, dynamic> j) => Donation(
        id: j['id']?.toString() ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        currency: j['currency']?.toString() ?? 'MZN',
        channel: (j['channel']?.toString() ?? 'CASH').toUpperCase(),
        donorName: j['donorName']?.toString(),
        memberNumber:
            j['memberNumber']?.toString() ?? j['memberId']?.toString(),
        receivedAt: DateTime.tryParse(
            j['receivedAt']?.toString() ?? j['createdAt']?.toString() ?? ''),
      );
}

/// An in-app notification row from `GET /communication/notifications/me`.
///
/// `payload` is free-form JSON written by whatever produced the notification,
/// so `title`/`body` pick the conventional keys out of it and degrade to a
/// readable string rather than rendering `{}` at the user.
class AppNotification {
  final String id;
  final String channel;
  final String template;
  final Map<String, dynamic> payload;
  final String status;
  final DateTime? createdAt;
  final DateTime? readAt;
  const AppNotification({
    required this.id,
    this.channel = 'IN_APP',
    this.template = '',
    this.payload = const {},
    this.status = 'PENDING',
    this.createdAt,
    this.readAt,
  });

  bool get unread => status.toUpperCase() != 'READ' && readAt == null;

  String? get title {
    final t = payload['title'] ?? payload['subject'];
    return t?.toString();
  }

  /// Best-effort human text: the explicit body, else the message/text keys,
  /// else the title, else nothing (the screen falls back to the template name).
  String? get body {
    final b = payload['body'] ?? payload['message'] ?? payload['text'];
    if (b != null && b.toString().trim().isNotEmpty) return b.toString();
    return title;
  }

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final raw = j['payload'];
    return AppNotification(
      id: j['id']?.toString() ?? '',
      channel: (j['channel']?.toString() ?? 'IN_APP').toUpperCase(),
      template: j['template']?.toString() ?? '',
      payload: raw is Map ? Map<String, dynamic>.from(raw) : const {},
      status: (j['status']?.toString() ?? 'PENDING').toUpperCase(),
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
      readAt: DateTime.tryParse(j['readAt']?.toString() ?? ''),
    );
  }
}
