/// توحيد النص العربي للبحث: يتجاهل التشكيل والتطويل، ويساوي بين أ/إ/آ/ا و ة/ه و ى/ي.
String normalizeArabic(String input) {
  var s = input.toLowerCase().trim();
  s = s.replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '');
  s = s.replaceAll(RegExp('[أإآٱ]'), 'ا');
  s = s.replaceAll('ة', 'ه').replaceAll('ى', 'ي');
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  return s;
}
