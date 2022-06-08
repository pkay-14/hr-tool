/**
 * @description Returns a wrapper. When it's called multiple times, it run 'callback' at maximum once per 'delay' milliseconds.
 * @example const inputFilterThrottle = window.throttle(sendFilterRequest, 1000)
 * @param callback {function}
 * @param delay {number} (milliseconds)
 */
function throttle(callback, delay = 500) {
  let isThrottled = false,
    savedArgs,
    savedThis;

  function wrapper() {
    if (isThrottled) {
      savedArgs = arguments;
      savedThis = this;
      return;
    }

    callback.apply(this, arguments);

    isThrottled = true;

    setTimeout(function () {
      isThrottled = false;
      if (savedArgs) {
        wrapper.apply(savedThis, savedArgs);
        savedArgs = savedThis = null;
      }
    }, delay);
  }

  return wrapper;
}
