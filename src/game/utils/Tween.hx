package game.utils;

class Tween {
    static public function linear(t: Float, b: Float, c: Float, d: Float): Float {
        return c * t / d + b;
    }
}