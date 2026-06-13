import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/pagination_list_view.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/fight_event/component/card/expandable_fighter_fight_event_card.dart';
import 'package:mma_flutter/fight_event/component/card/fighter_fight_event_card.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_pagination_provider.dart';
import 'package:mma_flutter/fight_event/repository/fight_event_repository.dart';
import 'package:mma_flutter/fighter/component/fighter_card.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/fighter/provider/fighter_pagination_provider.dart';
import 'package:mma_flutter/fighter/repository/fighter_repository.dart';
import 'package:mma_flutter/fighter/screen/fighter_detail_screen.dart';
import 'package:mma_flutter/main.dart';

class SearchScreen extends ConsumerStatefulWidget {

  static String get routeName => 'search';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();
  String _inputText = '';
  List<String> selectedNames = [];
  bool isFighterCategorySelected = true;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _searchBar(),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: SizedBox(
                  height: 24.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _renderCategoryButton(
                        label: '선수',
                        isFighterCategory: true,
                      ),
                      SizedBox(width: 7.w),
                      _renderCategoryButton(
                        label: '이벤트',
                        isFighterCategory: false,
                      ),
                    ],
                  ),
                ),
              ),
              if (isFighterCategorySelected) _renderFighterCards(),
              if (!isFighterCategorySelected) _renderFightEventCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SizedBox(
        height: 38.h,
        child: TextFormField(
          controller: _textController,
          onChanged: onChanged,
          style: context.text.bodyMedium,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 5.h, bottom: 5.h, left: 16.w),
            hintText: '검색어를 입력하세요',
            hintStyle: TextStyle(
              color: GREY_COLOR,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
            border: linearGradientInputBorder,
            prefixIcon: Icon(Icons.search, color: context.colors.onSurface),
          ),
        ),
      ),
    );
  }

  void onChanged(String value) {
    if(value.trim().isNotEmpty) {
      if (isFighterCategorySelected) {
        ref
            .read(fighterPaginationProvider.notifier)
            .paginateWithDebounce(params: {'name': value}, forceRefetch: true);
      } else {
        ref
            .read(fightEventPaginationProvider.notifier)
            .paginateWithDebounce(params: {'name': value}, forceRefetch: true);
      }
      setState(() {
        _inputText = value;
      });
    }
  }

  Widget _renderCategoryButton({
    required String label,
    required bool isFighterCategory,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor:
            isFighterCategory == isFighterCategorySelected
                ? BLUE_COLOR
                : DARK_GREY_COLOR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      onPressed: () {
        setState(() {
          isFighterCategorySelected = !isFighterCategorySelected;
        });
      },
      child: Text(label, style: defaultTextStyle.copyWith(fontSize: 12.sp)),
    );
  }

  _renderFighterCards() {
    return Expanded(
      child: PaginationListView<FighterModel, FighterRepository>(
        provider: fighterPaginationProvider,
        itemBuilder: (context, index, model) {
          return InkWell(
            onTap: () {
              context.pushNamed(
                FighterDetailScreen.routeName,
                pathParameters: {'id': model.id.toString()},
              );
            },
            child: SimpleFighterCard(fighter: model),
          );
        },
        params: {'name': _inputText},
        // loadingWidget: FighterCardSkeleton(),
      ),
    );
  }

  _renderFightEventCards() {
    return Expanded(
      child: PaginationListView<FighterFightEventModel, FightEventRepository>(
        provider: fightEventPaginationProvider,
        itemBuilder: (context, index, model) {
          return Row(
            children: [
              ExpandableFighterFightEventCard(ffe: model,),
            ],
          );
        },
        params: {'name': _inputText},
        // loadingWidget: FighterFightEventCardSkeleton(isHeaderIncluded: true),
      ),
    );
  }
}
