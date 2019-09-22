import 'package:drag_select_grid_view/src/auto_scroll/auto_scroll.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

void main() {
  const distanceFromTop = 80.0;
  const distanceFromRight = 40.0;
  const distanceFromBottom = 60.0;
  const distanceFromLeft = 20.0;
  const widgetHeight = screenHeight - (distanceFromTop + distanceFromBottom);
  const widgetWidth = screenWidth - (distanceFromRight + distanceFromLeft);

  final dragSelectGridViewFinder = find.byType(DragSelectGridView);

  Widget createWidget() {
    return MaterialApp(
      home: Column(children: [
        Container(height: distanceFromTop),
        Expanded(
          child: Row(children: [
            Container(width: distanceFromLeft),
            Expanded(
              child: DragSelectGridView(
                itemCount: 0,
                itemBuilder: (_, __, ___) => SizedBox(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 1,
                ),
              ),
            ),
            Container(width: distanceFromRight),
          ]),
        ),
        Container(height: distanceFromBottom),
      ]),
    );
  }

  group('Hotspot presence tests', () {
    testWidgets(
      "When the pointer gets inside the UPPER hotspot, "
      "then `AutoScroller` detects the pointer in the UPPER hotspot.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        expect(dragSelectGridViewFinder, findsOneWidget);
        DragSelectGridViewState state = tester.state(dragSelectGridViewFinder);

        final offset = Offset(0, 0);

        expect(state.isInsideUpperAutoScrollHotspot(offset), isTrue);
        expect(state.isInsideLowerAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets inside the LOWER hotspot, "
      "then `AutoScroller` detects the pointer in the LOWER hotspot.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState state = tester.state(dragSelectGridViewFinder);
        final offset = Offset(0, widgetHeight);

        expect(state.isInsideUpperAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideLowerAutoScrollHotspot(offset), isTrue);
      },
    );

    testWidgets(
      "When the pointer gets ABOVE both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState state = tester.state(dragSelectGridViewFinder);
        final offset = Offset(0, -1);

        expect(state.isInsideUpperAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideLowerAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets BELOW both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState state = tester.state(dragSelectGridViewFinder);
        final offset = Offset(0, widgetHeight + 1);

        expect(state.isInsideUpperAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideLowerAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets to the left side of both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState state = tester.state(dragSelectGridViewFinder);
        final offset = Offset(-1, 0);

        expect(state.isInsideUpperAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideLowerAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets to the right side of both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState state = tester.state(dragSelectGridViewFinder);
        final offset = Offset(widgetWidth + 1, 0);

        expect(state.isInsideUpperAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideLowerAutoScrollHotspot(offset), isFalse);
      },
    );
  });

  group('Auto-scroll tests', () {
    testWidgets(
      "Auto-scroll direction is updated "
      "when `DragSelectGridView` starts to scroll backward, "
      "but auto-scroll doesn't change "
      "when trying to scroll backward again.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState dragSelectGridViewState =
            tester.state(dragSelectGridViewFinder);

        // First scroll backward attempt.

        expect(dragSelectGridViewState.autoScroll.isScrolling, isFalse);
        expect(dragSelectGridViewState.autoScroll.direction, null);

        dragSelectGridViewState.startAutoScrollingBackward();

        expect(dragSelectGridViewState.autoScroll.isScrolling, isTrue);
        expect(
          dragSelectGridViewState.autoScroll.direction,
          AutoScrollDirection.backward,
        );

        // Second scroll backward attempt.

        final oldAutoScroll = dragSelectGridViewState.autoScroll;

        dragSelectGridViewState.startAutoScrollingBackward();

        expect(
          identical(oldAutoScroll, dragSelectGridViewState.autoScroll),
          isTrue,
        );
      },
    );

    testWidgets(
      "Auto-scroll direction is updated "
      "when `DragSelectGridView` starts to scroll forward, "
      "but auto-scroll doesn't change "
      "when trying to scroll forward again.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState dragSelectGridViewState =
            tester.state(dragSelectGridViewFinder);

        // First scroll forward attempt.

        expect(dragSelectGridViewState.autoScroll.isScrolling, isFalse);
        expect(dragSelectGridViewState.autoScroll.direction, null);

        dragSelectGridViewState.startAutoScrollingForward();

        expect(dragSelectGridViewState.autoScroll.isScrolling, isTrue);
        expect(
          dragSelectGridViewState.autoScroll.direction,
          AutoScrollDirection.forward,
        );

        // Second scroll forward attempt.

        final oldAutoScroll = dragSelectGridViewState.autoScroll;

        dragSelectGridViewState.startAutoScrollingForward();

        expect(
          identical(oldAutoScroll, dragSelectGridViewState.autoScroll),
          isTrue,
        );
      },
    );

    testWidgets(
      "Auto-scroll is updated "
      "when stop scrolling, "
      "but auto-scroll doesn't change "
      "when trying to stop scrolling again.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        DragSelectGridViewState dragSelectGridViewState =
            tester.state(dragSelectGridViewFinder);

        dragSelectGridViewState.startAutoScrollingForward();

        // First stop attempt.

        expect(dragSelectGridViewState.autoScroll.isScrolling, isTrue);
        expect(
          dragSelectGridViewState.autoScroll.direction,
          AutoScrollDirection.forward,
        );

        dragSelectGridViewState.stopScrolling();

        expect(dragSelectGridViewState.autoScroll.isScrolling, isFalse);
        expect(
          dragSelectGridViewState.autoScroll.direction,
          AutoScrollDirection.forward,
        );

        // Second stop attempt.

        final oldAutoScroll = dragSelectGridViewState.autoScroll;

        dragSelectGridViewState.stopScrolling();

        expect(
          identical(oldAutoScroll, dragSelectGridViewState.autoScroll),
          isTrue,
        );
      },
    );
  });
}
