package game;

@:nullSafety(Off)
class Main extends hxd.App {
    public static var app: Main;
    public var state: game.states.State;

    override function init() {
        Block.init();
        state = new game.states.GameState();
    }

    override function onResize() {
        state.onResize();
    }

    override function update(dt: Float) {
        state.update(dt);
    }

    override function render(e: h3d.Engine) {
        state.render(e);
    }

    static function main() {
        hxd.Res.initEmbed();
        app = new Main();
    }
}