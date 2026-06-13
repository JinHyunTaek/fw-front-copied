import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/setting/inquiry/faq/model/faq_response_model.dart';
import 'package:mma_flutter/setting/inquiry/faq/repository/faq_repository.dart';

final faqsFromCategoryFutureProvider = FutureProvider.family((ref, FAQCategory faqCategory) {
  return ref.read(faqRepositoryProvider).faqsFromCategory(category: faqCategory.requestValue);
},);

final faqsFutureProvider = FutureProvider((ref) {
  return ref.read(faqRepositoryProvider).getFaqs();
},);