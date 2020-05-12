package game;

import game.utils.Tween;
import h3d.Camera;
import game.utils.Timer;
import h3d.Vector;

class CameraController {
    static var HEIGHT = 20;
    static var TARGET_HEIGHT = 5;
    static var ANGLES = [
        new Point(-1, -1),
        new Point( 1, -1),
        new Point( 1,  1),
        new Point(-1,  1)
    ];
    static var OFFSETS = [
        new Point( 1,  0),
        new Point( 0,  1),
        new Point(-1,  0),
        new Point( 0, -1)
    ];
    var camera: Camera;
    var time = 0.;
    public var distance: Float = 20;
    public var last_angle = ANGLES[0];
    public var angle = ANGLES[0];
    public var angle_real = ANGLES[0].clone();
    public var angle_tween = Timer.dummy();
    public var shake_offset = new Vector();
    public var shake_timer = Timer.dummy();
    public var shake_mult = .25;

    public function new(camera) {
        this.camera = camera;

        camera.pos.z = HEIGHT;
        camera.target.z = TARGET_HEIGHT;

        angle_tween = new Timer(.25, false, null, function(timer) {
            trace(angle);
            angle_real.x = Tween.linear(timer.elapsed, last_angle.x, angle.x - last_angle.x, timer.duration);
            angle_real.y = Tween.linear(timer.elapsed, last_angle.y, angle.y - last_angle.y, timer.duration);
        }, true);

        shake_timer = new Timer(.1, false, function(_) {
            shake_offset.set();
        }, function(_) {
            shake_offset.set(
                Math.random() * shake_mult,
                Math.random() * shake_mult,
                Math.random() * shake_mult
            );
        }, true);
    }

    public function update(dt) {
        time += dt;

        angle_tween.update(dt);
        shake_timer.update(dt);

        camera.pos.x = Math.sin(time) + distance * angle_real.x + shake_offset.x;
        camera.pos.y = Math.cos(time) + distance * angle_real.y + shake_offset.y;
        camera.pos.z = HEIGHT + shake_offset.z;
        camera.target = shake_offset.clone();
        camera.target.z += TARGET_HEIGHT;
    }

    public function cycleAngle(times=1, tween=true) {
        last_angle = angle;
        var index = (ANGLES.indexOf(angle) + times) % ANGLES.length;
        if (index < 0) index += ANGLES.length;
        angle = ANGLES[index];
        if (tween) angle_tween.reset();
    }

    public function offsetFromAngle(offset=0) {
        return OFFSETS[(ANGLES.indexOf(angle) + offset) % ANGLES.length];
    }

    public function angleIndex() {
        return ANGLES.indexOf(angle);
    }
}