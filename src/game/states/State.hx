package game.states;

class State {
    var s2d: h2d.Scene;
    var s3d: h3d.scene.Scene;

    var time: Float = 0;

    public function new() {
        this.s2d = Main.app.s2d;
        this.s3d = Main.app.s3d;
    }

    public function update(dt: Float) {
        time += dt;
    }

    public function onResize() {}

    public function render(e: h3d.Engine) {
        s3d.render(e);
        s2d.render(e);
    }
}