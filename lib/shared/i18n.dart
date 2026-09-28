import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';

/// Lightweight bilingual string table. Default is pt-MZ (Mozambique).
/// English is provided for the demo audience that doesn't speak Portuguese.
///
/// Add new keys to BOTH maps. The `tr()` extension reads the active locale
/// from `localeProvider` and falls back to the key itself if a translation
/// is missing — so a forgotten string shows up as a clear visual gap rather
/// than crashing the screen.
const Map<String, Map<String, String>> _strings = {
  'pt': {
    'app.name': 'FRELIMO',
    'app.tagline': 'Frente de Libertação de Moçambique',
    'common.signIn': 'Iniciar Sessão',
    'common.signOut': 'Terminar Sessão',
    'common.continue': 'Continuar',
    'common.cancel': 'Cancelar',
    'common.save': 'Guardar',
    'common.share': 'Partilhar',
    'common.download': 'Descarregar',
    'common.loading': 'A carregar...',
    'common.retry': 'Tentar novamente',
    'common.comingSoon': 'Em breve',
    'common.payNow': 'Pagar agora',
    'common.error': 'Ocorreu um erro',

    'login.welcome': 'Bem-vindo',
    'login.subtitle': 'Aceda à sua conta FRELIMO',
    'login.email': 'Email institucional ou pessoal',
    'login.password': 'Palavra-passe',
    'login.forgot': 'Esqueceu a palavra-passe?',
    'login.cta': 'Iniciar Sessão',

    'forgot.title': 'Recuperar palavra-passe',
    'forgot.subtitle': 'Indique o seu email e enviaremos instruções.',
    'forgot.cta': 'Enviar instruções',
    'forgot.sent': 'Verifique o seu email.',

    'badge.leadershipNational': 'Liderança Nacional',
    'badge.leadershipProvincial': 'Liderança Provincial',
    'badge.coordination': 'Coordenação',
    'badge.official': 'Quadro do Partido',
    'badge.member': 'Militante Verificado',
    'badge.pending': 'Adesão Pendente',
    'badge.suspended': 'Suspenso',
    'badge.citizen': 'Cidadão',

    'home.welcome': 'Bem-vindo,',
    'home.status.citizen': 'CIDADÃO',
    'home.status.pending': 'PENDENTE',
    'home.status.verified': 'MEMBRO VERIFICADO',
    'home.status.suspended': 'SUSPENSO',
    'home.applyMembership': 'Pedir adesão como membro',
    'home.tile.card': 'Cartão',
    'home.tile.dues': 'Quotas',
    'home.tile.vote': 'Votar',
    'home.tile.surveys': 'Sondagens',
    'home.tile.report': 'Reportar',
    'home.tile.suggest': 'Sugestão',
    'home.tile.notifications': 'Notificações',
    'home.recentNews': 'Notícias recentes',

    'card.title': 'Cartão Digital',
    'card.memberSince': 'Membro desde',
    'card.province': 'Província',
    'card.district': 'Distrito',
    'card.ward': 'Posto Administrativo',
    'card.cell': 'Célula',
    'card.tapToVerify': 'Aponte para verificar',
    'card.suspended': 'Cartão suspenso',
    'card.expired': 'Cartão expirado',
    'card.pending': 'Aguarda verificação',

    'profile.title': 'Perfil',
    'profile.firstName': 'Nome',
    'profile.lastName': 'Apelido',
    'profile.phone': 'Telefone',
    'profile.street': 'Rua',
    'profile.neighbourhood': 'Bairro',
    'profile.town': 'Cidade',
    'profile.geography': 'Localização administrativa',

    'dues.title': 'Quotas',
    'dues.paid': 'PAGA',
    'dues.due': 'EM ABERTO',
    'dues.overdue': 'EM ATRASO',
    'dues.amount': 'Montante',
    'dues.phone': 'Número M-Pesa',
    'dues.payVia': 'Método',

    'admin.dashboard': 'Painel',
    'admin.members': 'Membros',
    'admin.verification': 'Verificação',
    'admin.news': 'Notícias',
    'admin.more': 'Mais',
    'admin.approve': 'Aprovar',
    'admin.suspend': 'Suspender',
    'admin.scanQr': 'Verificar Cartão (QR)',
    'admin.broadcasts': 'Comunicados',
    'admin.audit': 'Registo de Auditoria',
    'admin.elections': 'Eleições',
    'admin.donations': 'Donativos',
    'admin.settings': 'Definições',
    'admin.signOut': 'Terminar Sessão',
    'admin.newBroadcast': 'Novo comunicado',
    'admin.newElection': 'Nova eleição',
    'admin.newDonation': 'Registar donativo',
    'admin.newArticle': 'Nova notícia',
    'admin.addCandidate': 'Adicionar candidato',
    'admin.openElection': 'Abrir eleição',
    'admin.closeElection': 'Encerrar eleição',
    'admin.channel': 'Canal',
    'admin.audience': 'Público',
    'admin.subject': 'Assunto',
    'admin.body': 'Mensagem',
    'admin.send': 'Enviar',
    'admin.sentTo': 'Enviado a {n} militantes',
    'admin.totalDonations': 'Total recebido',
    'admin.donor': 'Doador',
    'admin.amount': 'Montante',
    'admin.method': 'Canal',
    'admin.memberNumber': 'Número de membro',
    'admin.scope': 'Âmbito',
    'admin.startsAt': 'Início',
    'admin.endsAt': 'Fim',
    'admin.filterAction': 'Filtrar por acção',
    'admin.actor': 'Actor',
    'admin.action': 'Acção',
    'admin.target': 'Alvo',
    'admin.ip': 'IP',
    'admin.timestamp': 'Data',

    'news.title': 'Notícias',
    'news.empty': 'Sem notícias ainda',
    'news.allCategories': 'Todas',
    'news.share': 'Partilhar',
    'news.read': 'Ler artigo',

    'voting.title': 'Eleições',
    'voting.open': 'Em curso',
    'voting.upcoming': 'Próximas',
    'voting.closed': 'Encerradas',
    'voting.empty': 'Sem eleições ainda',
    'voting.candidates': 'Candidatos',
    'voting.vote': 'Votar',
    'voting.confirmTitle': 'Confirmar voto',
    'voting.confirmBody': 'Tem a certeza? O voto é definitivo.',
    'voting.voted': 'Já votou nesta eleição',
    'voting.notOpen': 'Eleição não está aberta',

    'notifications.title': 'Notificações',
    'notifications.empty': 'Sem notificações ainda',
    'notifications.markRead': 'Marcar como lida',
    'notifications.read': 'Lida',

    'surveys.title': 'Sondagens',
    'surveys.empty': 'Sem sondagens abertas',
    'surveys.toAnswer': 'Por responder',
    'surveys.answered': 'Respondida',
    'surveys.submit': 'Submeter',
    'surveys.submitted': 'Resposta enviada',
    'surveys.unknownType': 'Tipo de pergunta não suportado',
    'surveys.yes': 'Sim',
    'surveys.no': 'Não',

    'report.title': 'Reportar incidente',
    'report.subject': 'Título',
    'report.description': 'Descrição',
    'report.category': 'Categoria',
    'report.location': 'Localização (opcional)',
    'report.submit': 'Enviar reporte',
    'report.success': 'Reporte recebido. Obrigado.',
    'report.cat.infra': 'Infraestrutura',
    'report.cat.services': 'Serviços Públicos',
    'report.cat.security': 'Segurança',
    'report.cat.health': 'Saúde',
    'report.cat.other': 'Outro',

    'suggest.title': 'Enviar sugestão',
    'suggest.subject': 'Assunto',
    'suggest.message': 'Mensagem',
    'suggest.category': 'Categoria',
    'suggest.submit': 'Enviar sugestão',
    'suggest.success': 'Sugestão enviada. Obrigado.',
    'suggest.cat.general': 'Geral',
    'suggest.cat.programme': 'Programa',
    'suggest.cat.comms': 'Comunicação',
    'suggest.cat.other': 'Outro',
  },
  'en': {
    'app.name': 'FRELIMO',
    'app.tagline': 'Mozambique Liberation Front',
    'common.signIn': 'Sign In',
    'common.signOut': 'Sign Out',
    'common.continue': 'Continue',
    'common.cancel': 'Cancel',
    'common.save': 'Save',
    'common.share': 'Share',
    'common.download': 'Download',
    'common.loading': 'Loading...',
    'common.retry': 'Retry',
    'common.comingSoon': 'Coming soon',
    'common.payNow': 'Pay now',
    'common.error': 'Something went wrong',

    'login.welcome': 'Welcome',
    'login.subtitle': 'Access your FRELIMO account',
    'login.email': 'Institutional or personal email',
    'login.password': 'Password',
    'login.forgot': 'Forgot password?',
    'login.cta': 'Sign In',

    'forgot.title': 'Reset password',
    'forgot.subtitle': 'Enter your email and we will send instructions.',
    'forgot.cta': 'Send instructions',
    'forgot.sent': 'Check your email.',

    'badge.leadershipNational': 'National Leadership',
    'badge.leadershipProvincial': 'Provincial Leadership',
    'badge.coordination': 'Coordination',
    'badge.official': 'Party Official',
    'badge.member': 'Verified Member',
    'badge.pending': 'Membership Pending',
    'badge.suspended': 'Suspended',
    'badge.citizen': 'Citizen',

    'home.welcome': 'Welcome,',
    'home.status.citizen': 'CITIZEN',
    'home.status.pending': 'PENDING',
    'home.status.verified': 'VERIFIED MEMBER',
    'home.status.suspended': 'SUSPENDED',
    'home.applyMembership': 'Apply for membership',
    'home.tile.card': 'Card',
    'home.tile.dues': 'Dues',
    'home.tile.vote': 'Vote',
    'home.tile.surveys': 'Surveys',
    'home.tile.report': 'Report',
    'home.tile.suggest': 'Suggestion',
    'home.tile.notifications': 'Alerts',
    'home.recentNews': 'Recent news',

    'card.title': 'Digital Card',
    'card.memberSince': 'Member since',
    'card.province': 'Province',
    'card.district': 'District',
    'card.ward': 'Ward',
    'card.cell': 'Cell',
    'card.tapToVerify': 'Scan to verify',
    'card.suspended': 'Card suspended',
    'card.expired': 'Card expired',
    'card.pending': 'Pending verification',

    'profile.title': 'Profile',
    'profile.firstName': 'First name',
    'profile.lastName': 'Last name',
    'profile.phone': 'Phone',
    'profile.street': 'Street',
    'profile.neighbourhood': 'Neighbourhood',
    'profile.town': 'Town',
    'profile.geography': 'Administrative geography',

    'dues.title': 'Dues',
    'dues.paid': 'PAID',
    'dues.due': 'DUE',
    'dues.overdue': 'OVERDUE',
    'dues.amount': 'Amount',
    'dues.phone': 'M-Pesa number',
    'dues.payVia': 'Method',

    'admin.dashboard': 'Dashboard',
    'admin.members': 'Members',
    'admin.verification': 'Verification',
    'admin.news': 'News',
    'admin.more': 'More',
    'admin.approve': 'Approve',
    'admin.suspend': 'Suspend',
    'admin.scanQr': 'Scan card (QR)',
    'admin.broadcasts': 'Broadcasts',
    'admin.audit': 'Audit log',
    'admin.elections': 'Elections',
    'admin.donations': 'Donations',
    'admin.settings': 'Settings',
    'admin.signOut': 'Sign out',
    'admin.newBroadcast': 'New broadcast',
    'admin.newElection': 'New election',
    'admin.newDonation': 'Record donation',
    'admin.newArticle': 'New article',
    'admin.addCandidate': 'Add candidate',
    'admin.openElection': 'Open election',
    'admin.closeElection': 'Close election',
    'admin.channel': 'Channel',
    'admin.audience': 'Audience',
    'admin.subject': 'Subject',
    'admin.body': 'Body',
    'admin.send': 'Send',
    'admin.sentTo': 'Sent to {n} members',
    'admin.totalDonations': 'Total received',
    'admin.donor': 'Donor',
    'admin.amount': 'Amount',
    'admin.method': 'Channel',
    'admin.memberNumber': 'Member number',
    'admin.scope': 'Scope',
    'admin.startsAt': 'Starts',
    'admin.endsAt': 'Ends',
    'admin.filterAction': 'Filter by action',
    'admin.actor': 'Actor',
    'admin.action': 'Action',
    'admin.target': 'Target',
    'admin.ip': 'IP',
    'admin.timestamp': 'Timestamp',

    'news.title': 'News',
    'news.empty': 'No news yet',
    'news.allCategories': 'All',
    'news.share': 'Share',
    'news.read': 'Read article',

    'voting.title': 'Elections',
    'voting.open': 'Open',
    'voting.upcoming': 'Upcoming',
    'voting.closed': 'Closed',
    'voting.empty': 'No elections yet',
    'voting.candidates': 'Candidates',
    'voting.vote': 'Vote',
    'voting.confirmTitle': 'Confirm vote',
    'voting.confirmBody': 'Are you sure? Your vote is final.',
    'voting.voted': 'You have already voted in this election',
    'voting.notOpen': 'Election is not open',

    'notifications.title': 'Notifications',
    'notifications.empty': 'No notifications yet',
    'notifications.markRead': 'Mark as read',
    'notifications.read': 'Read',

    'surveys.title': 'Surveys',
    'surveys.empty': 'No open surveys',
    'surveys.toAnswer': 'To answer',
    'surveys.answered': 'Answered',
    'surveys.submit': 'Submit',
    'surveys.submitted': 'Response submitted',
    'surveys.unknownType': 'Unsupported question type',
    'surveys.yes': 'Yes',
    'surveys.no': 'No',

    'report.title': 'Report an issue',
    'report.subject': 'Title',
    'report.description': 'Description',
    'report.category': 'Category',
    'report.location': 'Location (optional)',
    'report.submit': 'Submit report',
    'report.success': 'Report received. Thank you.',
    'report.cat.infra': 'Infrastructure',
    'report.cat.services': 'Public Services',
    'report.cat.security': 'Security',
    'report.cat.health': 'Health',
    'report.cat.other': 'Other',

    'suggest.title': 'Send suggestion',
    'suggest.subject': 'Subject',
    'suggest.message': 'Message',
    'suggest.category': 'Category',
    'suggest.submit': 'Send suggestion',
    'suggest.success': 'Suggestion sent. Thank you.',
    'suggest.cat.general': 'General',
    'suggest.cat.programme': 'Programme',
    'suggest.cat.comms': 'Communication',
    'suggest.cat.other': 'Other',
  },
};

class LocaleNotifier extends StateNotifier<Locale> {
  final SecureStorage _storage;
  LocaleNotifier(this._storage) : super(const Locale('pt')) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.getLocale();
    if (saved != null && _strings.containsKey(saved)) {
      state = Locale(saved);
    }
  }

  Future<void> set(String code) async {
    if (!_strings.containsKey(code)) return;
    await _storage.saveLocale(code);
    state = Locale(code);
  }

  Future<void> toggle() => set(state.languageCode == 'pt' ? 'en' : 'pt');
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(SecureStorage());
});

extension Tr on String {
  String tr(WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;
    return _strings[code]?[this] ?? _strings['pt']?[this] ?? this;
  }
}

/// Outside-widget lookup (e.g. inside a service / formatter). Use `tr()` from
/// widgets where possible — this variant doesn't react to locale changes.
String trStatic(String key, Locale locale) =>
    _strings[locale.languageCode]?[key] ?? _strings['pt']?[key] ?? key;
