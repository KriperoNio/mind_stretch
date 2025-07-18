import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/logic/cubit/article_bloc.dart';

class ArticleView extends StatelessWidget {
  const ArticleView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<ArticleCubit, ArticleState>(
        buildWhen: (old, next) => old != next,
        builder: (context, state) {
          switch (state) {
            case ArticleInitial() || ArticleLoading():
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            case ArticleLoaded():
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Не замарачиваюсь со Stack!
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          state.title ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => context.read<ArticleCubit>().refresh(),
                        icon: const Icon(Icons.refresh),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  RepaintBoundary(
                    child: Text(
                      state.article?.extract ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            case ArticleError():
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(state.message)),
              );
          }
        },
      ),
    );
  }
}
