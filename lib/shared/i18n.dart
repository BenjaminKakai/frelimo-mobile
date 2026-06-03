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
