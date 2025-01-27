import 'package:flutter/material.dart';

import '../app.dart';
import 'actions.dart';
import 'model.dart';
import 'sections/code_section.dart';
import 'sections/layout_section.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  var _showAllLinks = true;
  void _toggleShowAllLinks() {
    setState(() {
      _showAllLinks = !_showAllLinks;
    });
  }

  var _showCode = true;
  void _toggleShowCode() {
    setState(() {
      _showCode = !_showCode;
    });
  }

  @override
  void initState() {
    super.initState();
    itemsActions.addEmptyItem(linkToParent: true);
    itemsHistory.addListener(() => setState(() {}));
    dragState.addListener(() => setState(() {}));
    hoverTracker.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _actions(),
        Expanded(
          child: _body(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _body() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 12),
        _layoutSection(),
        if (_showCode) ...[
          const SizedBox(width: 12),
          _codeSection(),
        ],
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: PlaygroundActions(
        onToggleLinks: _toggleShowAllLinks,
        onToggleCode: _toggleShowCode,
      ),
    );
  }

  Widget _layoutSection() {
    return Expanded(
      flex: 2,
      child: PlaygroundSectionPane(
        child: PlaygroundLayoutSection(
          showAllLinks: _showAllLinks,
        ),
      ),
    );
  }

  Widget _codeSection() {
    return const Expanded(
      flex: 1,
      child: PlaygroundSectionPane(
        child: PlaygroundCodeSection(),
      ),
    );
  }
}

class PlaygroundSectionPane extends StatelessWidget {
  const PlaygroundSectionPane({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(width: 0.5, color: Colors.grey),
        ),
      ),
      child: child,
    );
  }
}
