# AsyncTask源码解析

首先，AsyncTask是一个抽象类，我们使用的时候需要自定义一个类去继承AsyncTask，在继承时我们可以为AsyncTask类指定三个泛型参数，这三个参数的用途如下：

1. `Params`

在执行AsyncTask时需要传入的参数，可用于在后台任务中使用。

2. `Progress`

后台任务执行时，如果需要在界面上显示当前的进度，则使用这里指定的泛型作为进度单位。

3. `Result`

当任务执行完毕后，如果需要对结果进行返回，则使用这里指定的泛型作为返回值类型。

在`AsyncTask`这个抽象类中有一个抽象方法`protected abstract Result doInBackground(Params... params)`，所以如果要自定义一个自己的`AsyncTask`必须实现该抽象方法，在`doInBackground`中做自己的耗时操作的逻辑。

几个回调方法：

1. `onPreExecute()`

这个方法会在后台任务开始执行之间调用，用于进行一些界面上的初始化操作，比如显示一个进度条对话框等。

2. `doInBackground(Params…)`

这个方法中的所有代码都会在子线程中运行，我们应该在这里去处理所有的耗时任务。任务一旦完成就可以通过`return`语句来将任务的执行结果进行返回，如果`AsyncTask`的第三个泛型参数指定的是`Void`，就可以不返回任务执行结果。注意，在这个方法中是不可以进行`UI操作`的，如果需要更新UI元素，比如说反馈当前任务的执行进度，可以调用`publishProgress(Progress…)`方法来完成。

3. `onProgressUpdate(Progress…)`

当在后台任务中调用了`publishProgress(Progress…)`方法后，这个方法就很快会被调用，方法中携带的参数就是在后台任务中传递过来的。在这个方法中可以对UI进行操作，利用参数中的数值就可以对界面元素进行相应的更新。

4. `onPostExecute(Result)`

当后台任务执行完毕并通过`return`语句进行返回时，这个方法就很快会被调用。返回的数据会作为参数传递到此方法中，可以利用返回的数据来进行一些UI操作，比如说提醒任务执行的结果，以及关闭掉进度条对话框等。

---------------------
## 构造方法

```java
 public AsyncTask(@Nullable Looper callbackLooper) {
        mHandler = callbackLooper == null || callbackLooper == Looper.getMainLooper()
            ? getMainHandler()
            : new Handler(callbackLooper);

        mWorker = new WorkerRunnable<Params, Result>() {
            public Result call() throws Exception {
                mTaskInvoked.set(true);
                Result result = null;
                try {
                    Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                    //noinspection unchecked
                    result = doInBackground(mParams);
                    Binder.flushPendingCommands();
                } catch (Throwable tr) {
                    mCancelled.set(true);
                    throw tr;
                } finally {
                    postResult(result);
                }
                return result;
            }
        };

        mFuture = new FutureTask<Result>(mWorker) {
            @Override
            protected void done() {
                try {
                    postResultIfNotInvoked(get());
                } catch (InterruptedException e) {
                    android.util.Log.w(LOG_TAG, e);
                } catch (ExecutionException e) {
                    throw new RuntimeException("An error occurred while executing doInBackground()",
                            e.getCause());
                } catch (CancellationException e) {
                    postResultIfNotInvoked(null);
                }
            }
        };
    }
```

在构造方法中没有执行过多的逻辑，只是初始化了三个对象：`Handler mHandler`、`WorkerRunnable<Params, Result> mWorker`、`FutureTask<Result> mFuture`

接着要想启动一个任务，我们就需要调用该任务的`excute()`方法

## excute（）

`excute()`方法的源码：

```java
public final AsyncTask<Params, Progress, Result> execute(Params... params) {
	return executeOnExecutor(sDefaultExecutor, params);
}

```

在`excute()`源码中调用了`executeOnExecutor`方法，传入了两个参数：`sDefaultExecutor`和`params`

## excuteOnExcutor（）

```java

public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
		Params... params) {
	if (mStatus != Status.PENDING) {
		switch (mStatus) {
			case RUNNING:
				throw new IllegalStateException("Cannot execute task:"
						+ " the task is already running.");
			case FINISHED:
				throw new IllegalStateException("Cannot execute task:"
						+ " the task has already been executed "
						+ "(a task can be executed only once)");
		}
	}
	mStatus = Status.RUNNING;
	onPreExecute();
	mWorker.mParams = params;
	exec.execute(mFuture);
	return this;
}

```

在该方法中先是调用了`onPreExecute()`方法，因此证明了`onPreExecute()`方法会第一个被调用，然后执行了`exec.execute(mFuture)`方法，这个`exec`实际上从`excute()`方法中传入的`sDefaultExecutor`。

## sDefaultExecutor

```java
public static final Executor SERIAL_EXECUTOR = new SerialExecutor();

private static volatile Executor sDefaultExecutor = SERIAL_EXECUTOR;
```

这里先`new`出了一个`SERIAL_EXECUTOR`常量，然后将`sDefaultExecutor`的值赋值为这个常量，也就是说明，刚才在`executeOnExecutor()`方法中调用的`execute()`方法，其实也就是调用的`SerialExecutor`类中的`execute()`方法。

## SerialExecutor

```java

private static class SerialExecutor implements Executor {
	final ArrayDeque<Runnable> mTasks = new ArrayDeque<Runnable>();
	Runnable mActive;
 
	public synchronized void execute(final Runnable r) {
		mTasks.offer(new Runnable() {
			public void run() {
				try {
					r.run();
				} finally {
					scheduleNext();
				}
			}
		});
		if (mActive == null) {
			scheduleNext();
		}
	}
 
	protected synchronized void scheduleNext() {
		if ((mActive = mTasks.poll()) != null) {
			THREAD_POOL_EXECUTOR.execute(mActive);
		}
	}
}

```

`SerialExecutor`类中有一个`ArrayDeque`的队列，还有一个当前的`Runnable mActive`对象，在`execute()`方法中，首先会用`mTasks.offer`给队列的尾部加入一个匿名的`Runnable`类，在该`Runnable`匿名类中执行了`excute`中传入的`Runnable`对象的`run`方法，然后调用`scheduleNext`，该方法使用`mTask.poll()`取出队列头部的任务，然后调用`THREAD_POOL_EXECUTOR.execute(mActive)`,这里的`THREAD_POOL_EXECUTOR`实际上是一个线程池，当当前队头的`run`方法执行完成之后又会在`try..finally`中调用`scheduleNext()`取出下一个任务进入线程池进行执行，所以可以看到，在`AsyncTask`中实际上有两个线程池，一个是`SerialExcutor`,另一个是`THREAD_POOL_EXCUTOR`,他们两是都是静态字段，对于所有的`AsyncTask`都会公用他们两，前者模仿的是单一线程池，用于做任务调度，利用队列将所有的任务排队，然后每次把队头的任务交给`THREAD_POOL_EXCUTOR`去做实际的执行，

注意`excute`方法中的`Runnable`参数，那么目前这个参数的值是什么呢？当然就是`mFuture`对象了，也就是说这里的`r.run()`实际上调用的是`FutureTask`类的run()方法，而我们刚才在构造`mFuture`的时候传入了`mWorker`,而`mWorker`的构造代码如下：

```java
mWorker = new WorkerRunnable<Params, Result>() {
            public Result call() throws Exception {
                mTaskInvoked.set(true);
                Result result = null;
                try {
                    Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                    //noinspection unchecked
                    result = doInBackground(mParams);
                    Binder.flushPendingCommands();
                } catch (Throwable tr) {
                    mCancelled.set(true);
                    throw tr;
                } finally {
                    postResult(result);
                }
                return result;
            }
        };
```

`WorkerRunnable`是一个抽象类，其实现了`Callable`接口，所以在这里实现了`Callable`接口需要的``call`方法，`call`方法里调用了`doInBackground()`方法，调用完成之后在`try..finally`中调用了`postResult()`方法将结果返回，而`postResult()`中：

```java
 private Result postResult(Result result) {
        @SuppressWarnings("unchecked")
        Message message = getHandler().obtainMessage(MESSAGE_POST_RESULT,
                new AsyncTaskResult<Result>(this, result));
        message.sendToTarget();
        return result;
    }

```

在这里使用`getHandler()`拿到刚才构造方法中的`mHandler`对象,然后发出了一条消息，消息中携带了`MESSAGE_POST_RESULT`常量和一个表示任务执行结果的`AsyncTaskResult`对象。而这个`mHandler`实际上是一个`InternalHandler`对象：

```java
private static class InternalHandler extends Handler {
        public InternalHandler(Looper looper) {
            super(looper);
        }

        @SuppressWarnings({"unchecked", "RawUseOfParameterizedType"})
        @Override
        public void handleMessage(Message msg) {
            AsyncTaskResult<?> result = (AsyncTaskResult<?>) msg.obj;
            switch (msg.what) {
                case MESSAGE_POST_RESULT:
                    // There is only one result
                    result.mTask.finish(result.mData[0]);
                    break;
                case MESSAGE_POST_PROGRESS:
                    result.mTask.onProgressUpdate(result.mData);
                    break;
            }
        }
    }

```

可以看到在该`InternalHander`的`handleMessage`方法中接收到了刚才发送的消息，并根据`msg.what`的不同调用了不同的逻辑，如果这是一条`MESSAGE_POST_RESULT`消息，就会去执行`finish()`方法，如果这是一条`MESSAGE_POST_PROGRESS`消息，就会去执行`onProgressUpdate()`方法。那么`finish()`方法的源码如下所示：

```java

private void finish(Result result) {
	if (isCancelled()) {
		onCancelled(result);
	} else {
		onPostExecute(result);
	}
	mStatus = Status.FINISHED;
}

```

可以看到，如果当前任务被取消掉了，就会调用`onCancelled()``方法，如果没有被取消，则调用onPostExecute()`方法，这样当前任务的执行就全部结束了。

我们注意到，在刚才`InternalHandler`的`handleMessage()`方法里，还有一种`MESSAGE_POST_PROGRESS`的消息类型，这种消息是用于当前进度的，调用的正是`onProgressUpdate()`方法，那么什么时候才会发出这样一条消息呢？相信你已经猜到了，查看`publishProgress()`方法的源码，如下所示：

```java

protected final void publishProgress(Progress... values) {
	if (!isCancelled()) {
		sHandler.obtainMessage(MESSAGE_POST_PROGRESS,
				new AsyncTaskResult<Progress>(this, values)).sendToTarget();
	}
}
```

正因如此，在`doInBackground()`方法中调用`publishProgress()`方法才可以从子线程切换到UI线程，从而完成对UI元素的更新操作。其实也没有什么神秘的，因为说到底，`AsyncTask`也是使用的异步消息处理机制，只是做了非常好的封装而已。

## 关于AsyncTask更深层次的解析

刚才提到的`THREAD_POOL_EXECUTOR`:

```java
private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
// We want at least 2 threads and at most 4 threads in the core pool,
// preferring to have 1 less than the CPU count to avoid saturating
// the CPU with background work
private static final int CORE_POOL_SIZE = Math.max(2, Math.min(CPU_COUNT - 1, 4));
private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
private static final int KEEP_ALIVE_SECONDS = 30;
static {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_SECONDS, TimeUnit.SECONDS,
                sPoolWorkQueue, sThreadFactory);
        threadPoolExecutor.allowCoreThreadTimeOut(true);
        THREAD_POOL_EXECUTOR = threadPoolExecutor;
    }
```

可以看到，AsyncTask实际上是对线程池`ThreadPoolExcutor`的封装，在实例化`ThreadPoolExcotor`的时候传入的核心线程数是在`2-4`个之间，最大线程数是`cpu count*2+1`个，我们在`SerialExecutor`的`scheduleNext`方法中使用该线程池去执行当前队头的任务，刚才提到了，`AsyncTask`的`SerialExecutor`线程池中做的调度是串行的，也就是说同时只会有一个线程被执行，那这里的`ThreadPoolExcutor`为什么没有初始化成`singleThreadPool`?这是一个疑问。

同时，`AsyncTas`k默认是串行执行任务的，如果想要并行，从`Android 3.0`开始`AsyncTask`增加了`executeOnExecutor`方法，用该方法可以让`AsyncTask`并行处理任务。方法签名如下： 

```java
public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
            Params... params)
```

`exec`是一个`Executor`对象，为了让`AsyncTask`并行处理任务，通常情况下我们此处传入`AsyncTask.THREAD_POOL_EXECUTOR`即可。 `AsyncTask.THREAD_POOL_EXECUTOR`是`AsyncTask`中内置的一个线程池对象，当然我们也可以传入我们自己实例化的线程池对象。第二个参数`params`表示的是要执行的任务的参数：

```java
Executor exec = new ThreadPoolExecutor(15, 200, 10,
		TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
new DownloadTask().executeOnExecutor(exec);
```

## 讲解流程

构造方法：<params、progress、result>{mHandler、mWork、mFuture}

excute（params）->excuteOnExcutor(sDefaultExcutor,params){mWork.params=params;onpreExcute();sDefaultExcutor.excute(mFuture)}

sDefaultExcutor->SerailExcutor implements Excutor{ArrayDeque<Runnable> mTasks;  excute(Runnable r){try{r.run()}finally{shedueNext(){THREAD_POOL_EXCUTOR.excute(mTask.poll())}}}}

mFuture:FutureTask(mWork)

mWork:WorkRunnable().call(){

result=Try{doInbackGround();

}finally{

PostResult(result);

}

}

postResult(result):mHandler.obtainMessage(MESSAGE_POST_RESULT,result);sendTotarget()

mHandler.handleMessage{msg.what 1:onPostExcute()2:onProgressUpdate()}



SerialExcutor

THREAD_POLL_EXCUTOR:ThreadPoolExcutor()



