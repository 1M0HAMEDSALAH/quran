import 'dart:async';

class Debouncer<T> {
  Debouncer({
    required this.duration,
    this.onChanged,
    required this.initialValue,
  }): _value = initialValue;

  final Duration duration;
  final void Function(T value)? onChanged;
  T initialValue;
  
  T _value;
  Timer? _timer;

  T get value => _value;

  set value(T val) {
    _value = val;
    _timer?.cancel();
    _timer = Timer(duration, () => onChanged?.call(_value));
  }

  void dispose() {
    _timer?.cancel();
  }
}