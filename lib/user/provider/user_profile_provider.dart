import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/user/model/user_profile_model.dart';
import 'package:mma_flutter/user/repository/user_repository.dart';

final userProfileProvider = FutureProvider.autoDispose<UserProfileModel>((ref) async {
  return await ref.read(userRepositoryProvider).profile();
});
