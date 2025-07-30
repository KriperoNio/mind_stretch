import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';
import 'package:mind_stretch/logic/cubit/settings/topic_chips_cubit.dart';

class TopicChipsCarousel extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelected;

  const TopicChipsCarousel({
    super.key,
    required this.onSelected,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicChipsCubit, TopicChipsState>(
      buildWhen: (previous, current) =>
          current is TopicChipsGeneration || current is TopicChipsGenerated,
      builder: (BuildContext context, state) {
        switch (state) {
          case TopicChipsInitial():
          case TopicChipsGeneration():
            return SizedBox(height: 40);
          case TopicChipsGenerated(:final chips):
            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: chips.length,
                itemBuilder: (context, index) {
                  final item = chips[index];
                  final isSelected = item == selected;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (_) => onSelected(item),
                    ),
                  );
                },
              ),
            );
          case TopicChipsError(:final error, :final message):
            AppLogger.error(message, error: error, name: 'TopicChipsCarousel');
            return SizedBox(height: 8);
        }
      },
    );
  }
}
