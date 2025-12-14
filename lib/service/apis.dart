/// همه لینک‌های سرویس‌ها
class ApiUrls {
  // جستجو
  static String thesaurusPaged(String query, int page) =>
      'https://apithesaurus.isca.ac.ir/v1/web/terms'
      '?search_type=5&word=${Uri.encodeComponent(query)}&domain=0&page=$page';

  static String indexPaged(String query, int page) =>
      'https://apithesaurus.isca.ac.ir/v1/web/search/index'
      '?word=${Uri.encodeComponent(query)}&page=$page';

  static String lexiconPaged(String query, int page) =>
      'https://apithesaurus.isca.ac.ir/v1/web/search/encyclopedia'
      '?word=${Uri.encodeComponent(query)}&page=$page';

  static String resourcesPaged(String query, int page) =>
      'https://apithesaurus.isca.ac.ir/v1/web/search/doc'
      '?word=${Uri.encodeComponent(query)}&page=$page';

  static const String lexicon =
      'https://apithesaurus.isca.ac.ir/v1/web/search/encyclopedia';
  static const String thesaurus =
      'https://apithesaurus.isca.ac.ir/v1/web/terms';
  static const String indexService =
      'https://apithesaurus.isca.ac.ir/v1/web/search/index';
  static const String resources =
      'https://apithesaurus.isca.ac.ir/v1/web/search/doc';

  // کتابخانه
  static const String latestDocs =
      'https://apithesaurus.isca.ac.ir/v1/docs/new';
  static const String stats =
      'https://apithesaurus.isca.ac.ir/v1/web/static/index';
  static const String newIndexed =
      'https://apithesaurus.isca.ac.ir/v1/docs/new_indexed';

  static String docIndexesTerms(int contentId) =>
      'https://apithesaurus.isca.ac.ir/v1/web/docs/indexes-terms/$contentId';

  static String docDetails(int id) =>
      'https://apithesaurus.isca.ac.ir/v1/web/docs/$id/details';

  static String docRead(int id) =>
      'https://apithesaurus.isca.ac.ir/v1/web/docs/$id';

  // اصطلاحنامه
  static const String thesaurusStats =
      'https://apithesaurus.isca.ac.ir/v1/web/static/term';

  static const String domains =
      'https://apithesaurus.isca.ac.ir/v1/domains';

  /// ✅ سرویس درختواره اصطلاحنامه
  static String thesaurusTree(String id) =>
      'https://apithesaurus.isca.ac.ir/v1/web/terms/$id/tree';

  /// ✅ سرویس جزئیات اصطلاحنامه
  static String thesaurusDetail(String slug) =>
      'https://apithesaurus.isca.ac.ir/v1/web/terms/$slug';

  /// سرویس نمایه اصطلاح
  static String indexForTerm(String id) =>
      'https://apithesaurus.isca.ac.ir/v1/term/$id/index?page=1';

  /// سرویس نمایه اصطلاح
  static String indexForTermPaged(String id, int page) =>
      'https://apithesaurus.isca.ac.ir/v1/term/$id/index?page=$page';

  /// سرویس فرهنگنامه اصطلاح
  static String lexiconForTerm(String id) =>
      'https://apithesaurus.isca.ac.ir/v1/term/$id/encyclopedia';

  /// سرویس منابع اصطلاح
  static String resourcesForTerm(String id) =>
      'https://apithesaurus.isca.ac.ir/v1/term/$id/resource';

  /// سرویس جستجوی اصطلاح (برای گرفتن id)
  static String searchTerm(String query) =>
      'https://apithesaurus.isca.ac.ir/v1/web/terms'
      '?search_type=5&word=${Uri.encodeComponent(query)}&domain=0&page=1';

  static String thesaurusPagedWithDomain(String query, int page, int domainId) =>
    'https://apithesaurus.isca.ac.ir/v1/web/terms'
    '?search_type=5&word=${Uri.encodeComponent(query)}&domain=$domainId&page=$page';

  // کاربر
  static const String login =
      'https://adminthesaurus.isca.ac.ir/login';

  static const String register =
      'https://apithesaurus.isca.ac.ir/v1/register';

  static const String forgotPassword = '';

  // استان‌ها
  static const String cities =
      'https://apithesaurus.isca.ac.ir/v1/cities';

  // نسخه‌های جدید برای شناسه‌های رشته‌ای
  static String docDetailsAny(String id) =>
      'https://apithesaurus.isca.ac.ir/v1/web/docs/$id/details';

  static String docReadAny(String id) =>
      'https://apithesaurus.isca.ac.ir/v1/web/docs/$id';

  static String docIndexesTermsAny(String contentId) =>
      'https://apithesaurus.isca.ac.ir/v1/web/docs/indexes-terms/$contentId';
}