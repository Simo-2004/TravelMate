import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  NavigationController? _controller;
  int _lastFocusRequest = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = NavigationScope.maybeControllerOf(context);

    if (_controller == nextController) {
      _handleController();
      return;
    }

    _controller?.removeListener(_handleController);
    _controller = nextController;
    _controller?.addListener(_handleController);
    _handleController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleController);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleController() {
    if (!mounted || _controller == null) {
      return;
    }

    final searchIndex = NavigationScope.indexOfLabel(
      context,
      AppStrings.navSearchLabel,
    );

    if (searchIndex == null || _controller!.index != searchIndex) {
      return;
    }

    if (_controller!.focusRequest == _lastFocusRequest) {
      return;
    }

    _lastFocusRequest = _controller!.focusRequest;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(sizes.padL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TravelSearchBar(
              autofocus: true,
              focusNode: _focusNode,
            ),
          ],
        ),
      ),
    );
  }
}
