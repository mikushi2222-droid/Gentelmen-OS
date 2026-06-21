import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? st)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ??
          const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, st) =>
          error?.call(e, st) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Что-то пошло не так:\n$e',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
    );
  }
}
