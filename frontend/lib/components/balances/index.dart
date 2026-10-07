import 'package:KKB/components/balances/header.dart';
import 'package:KKB/components/global/label.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalancesIndex extends ConsumerStatefulWidget {
  const BalancesIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MGroupsIndexState();
}

class _MGroupsIndexState extends ConsumerState<BalancesIndex> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(BalanceHeader.toolbarHeightForTwoLineTitle),
        child: const BalanceHeader(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              //search bar
              KKBTextField(
                hintText: 'Search groups',
                prefixIcon: Icon(Icons.search),
                onChanged: (value) {
                  
                },
              ),
              const SizedBox(height: 16),
              KKBLabel(title: 'Favorites', subtitle: 'Swipe for more', leading: SvgIcon(icon: KKBIcons.starFilled, color: KKBColors.lightLink)),


              const SizedBox(height: 16),
              KKBLabel(title: 'My groups', subtitle: 'Created by you • 3'),


              const SizedBox(height: 16),
              KKBLabel(title: 'Joined groups', subtitle: 'Created by others • 3')
            ],
          ),
        ),
      ),
    );
  }
}