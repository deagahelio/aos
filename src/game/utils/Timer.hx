package game.utils;

class Timer {
    public var elapsed = 0.;
    public var duration: Float;
    public var repeat: Bool;
    public var finished = false;
    public var paused = false;
    var finished_callback: Null<Timer -> Void>;
    var update_callback: Null<Timer -> Void>;

    public function new(duration, repeat=false, ?finished_callback, ?update_callback) {
        this.duration = duration;
        this.repeat = repeat;
        this.finished_callback = finished_callback;
        this.update_callback = update_callback;
    }

    public function update(time: Float): Bool {
        if (paused || finished)
            return false;

        elapsed += time;
        if (elapsed >= duration) {
            if (repeat) {
                elapsed = 0;
            } else {
                elapsed = duration;
                finished = true;
            }

            if (update_callback != null)
                update_callback(this);

            if (finished_callback != null)
                finished_callback(this);

            return true;
        } else {
            if (update_callback != null)
                update_callback(this);

            return false;
        }
    }

    public function reset() {
        elapsed = 0;
        finished = false;
        paused = false;
    }
}