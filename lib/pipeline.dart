/// Defines a queue of [PipelineTask] to be executed, with the output of the previous task
/// being the input to the next. The [PipelineTask]'s are executed in the order they are added.
///
/// A [PipelineTask] may be added to the queue by calling [next()], and returns a `Pipeline<T>`
/// where `T` is the output of the previously added [PipelineTask].
class Pipeline<From> {
  const Pipeline._(this._initialValue, this._tasks);

  static Pipeline<Into> start<Start, Into>(
    Start initialValue,
    PipelineTask<Start, Into> task,
  ) =>
      Pipeline._(initialValue, [task.downcast()]);

  final dynamic _initialValue;
  final List<PipelineTask> _tasks;

  From run() {
    dynamic out = _initialValue;
    for (final task in _tasks) {
      out = task(out);
    }
    return out as From;
  }

  Pipeline<Into> next<Into>(PipelineTask<From, Into> next) {
    return Pipeline._(_initialValue, [..._tasks, next.downcast()]);
  }
}

/// An individual task in a [Pipeline].
typedef PipelineTask<From, Into> = Into Function(From from);

extension<From, Into> on PipelineTask<From, Into> {
  PipelineTask downcast() => (dynamic x) => this(x as From);
}
