# Pipeline

Defines a queue of `PipelineTask`'s to be executed, with the output of the previous task
being the input to the next. The `PipelineTask`'s are executed in the order they are added.

A `PipelineTask` may be added to the queue by calling `next()`, and returns a `Pipeline<T>`
where `T` is the output of the previously added `PipelineTask`.
