package game.states;

import game.utils.Timer;
import game.utils.Tween;
import game.Block;
import hxd.Key;
import h2d.Tile;
import h2d.Bitmap;
import h3d.Vector;
import h3d.scene.fwd.DirLight;
import hxd.Res;

using Safety;

class GameState extends State implements IBoard {
    static var SPAWN_HEIGHT = 10;
    static var PLATFORM_RADIUS = 2;
    static var PLATFORM_AREA = Math.pow(PLATFORM_RADIUS * 2 + 1, 2);
    var bg_scene: h2d.Scene;
    var bg_tile: Tile;
    var bg: Bitmap;
    public var blocks: Array<Block> = [];
    var camera: CameraController;
    var piece: Piece;
    var last_piece_color: Int;
    var fall_timer = new Timer(2, true);
    var fade_tween = Timer.dummy();

    public function new() {
        super();

        bg_scene = new h2d.Scene();
        bg_tile = Res.space2.toTile();
        bg = new Bitmap(bg_tile, bg_scene);
        bg.tileWrap = true;
        bg_tile.setSize(s2d.width, s2d.height);

        var light = new DirLight(new Vector(0, 0, -1), s3d);
        light.enableSpecular = true;

        s3d.lightSystem.ambientLight.setColor(0x909090);

        for (x in -PLATFORM_RADIUS...PLATFORM_RADIUS + 1) {
            for (y in -PLATFORM_RADIUS...PLATFORM_RADIUS + 1) {
                blocks.push(new Block(s3d, x, y));
            }
        }

        camera = new CameraController(s3d.camera);

        last_piece_color = Std.random(7) + 2;
        piece = new Piece(this, s3d, 0, 0, SPAWN_HEIGHT, last_piece_color);
    }

    override function update(dt: Float) {
        super.update(dt);

        if (Key.isPressed(Key.Q)) camera.cycleAngle();
        if (Key.isPressed(Key.E)) camera.cycleAngle(-1);
        if (Key.isDown(Key.CTRL) || Key.isDown(Key.TAB) || Key.isDown(Key.SHIFT) || Key.isDown(Key.ALT)) {
            var index = camera.angleIndex();
            var dirs = [0, 2, 1, 3];
            if (Key.isPressed(Key.NUMPAD_7) || Key.isPressed(Key.I)) piece.rotate(dirs[(0 + index) % 4]);
            if (Key.isPressed(Key.NUMPAD_8) || Key.isPressed(Key.O)) piece.rotate(dirs[(1 + index) % 4]);
            if (Key.isPressed(Key.NUMPAD_5) || Key.isPressed(Key.L)) piece.rotate(dirs[(2 + index) % 4]);
            if (Key.isPressed(Key.NUMPAD_4) || Key.isPressed(Key.K)) piece.rotate(dirs[(3 + index) % 4]);
        } else {
            var offset: Null<Point> = null;
            if (Key.isPressed(Key.NUMPAD_7) || Key.isPressed(Key.I)) offset = camera.offsetFromAngle();
            if (Key.isPressed(Key.NUMPAD_8) || Key.isPressed(Key.O)) offset = camera.offsetFromAngle(1);
            if (Key.isPressed(Key.NUMPAD_5) || Key.isPressed(Key.L)) offset = camera.offsetFromAngle(2);
            if (Key.isPressed(Key.NUMPAD_4) || Key.isPressed(Key.K)) offset = camera.offsetFromAngle(3);
            if (offset != null) piece.move(offset.x, offset.y, offset.z);
        }
        if (Key.isPressed(Key.F4)) reset();

        camera.update(dt);
        fade_tween.update(dt);

        if (Key.isDown(Key.NUMPAD_0) || Key.isDown(Key.QWERTY_COMMA)) fall_timer.elapsed += dt * 7;
        if (fall_timer.update(dt))
            if (piece.move(0, 0, -1))
                nextPiece();

        piece.update(dt);
    }

    function nextPiece() {
        for (block in piece.blocks)
            blocks.push(block);

        piece.blocks = [];
        piece.remove();

        var new_color;
        do {
            new_color = Std.random(7) + 2;
        } while (new_color == last_piece_color);

        piece = new Piece(this, s3d, 0, 0, SPAWN_HEIGHT, new_color);
        last_piece_color = new_color;

        checkLines();

        camera.shake_timer.reset();
    }

    function checkLines() {
        for (z in 1...10) {
            var layer = blocks.filter(function(block) {
                return
                    block.z == z &&
                    -PLATFORM_RADIUS <= block.x &&
                    block.x <= PLATFORM_RADIUS &&
                    -PLATFORM_RADIUS <= block.y &&
                    block.y <= PLATFORM_RADIUS;
            });

            if (layer.length == PLATFORM_AREA) {
                for (block in layer) {
                    block.remove();
                    blocks.remove(block);
                }

                for (block in blocks) {
                    if (block.z > z) {
                        block.z--;
                        block.syncPos();
                    }
                }
            }
        }
    }

    override function render(e: h3d.Engine) {
        bg_scene.render(e);
        super.render(e);
    }

    function reset() {
        if (!fade_tween.finished) return;

        fade_tween = new Timer(.5, false, function(timer) {
            for (block in blocks.concat(piece.blocks).concat(piece.ghost_blocks)) {
                block.mesh.remove();
            }

            blocks = [];
            for (x in -PLATFORM_RADIUS...PLATFORM_RADIUS + 1) {
                for (y in -PLATFORM_RADIUS...PLATFORM_RADIUS + 1) {
                    blocks.push(new Block(s3d, x, y, 0, 0));
                }
            }

            piece = new Piece(this, s3d, 0, 0, SPAWN_HEIGHT, Std.random(7) + 2);
            last_piece_color = piece.color;
            fall_timer.reset();

            camera = new CameraController(s3d.camera);

            fade_tween = new Timer(.5, false, null, function(timer) {
                for (block in blocks.concat(piece.blocks).concat(piece.ghost_blocks)) {
                    block.mesh.setScale(Tween.linear(timer.elapsed, 0, 1, timer.duration));
                }
            });
            fade_tween.sure().update(0);
        }, function(timer) {
            for (block in blocks.concat(piece.blocks).concat(piece.ghost_blocks)) {
                block.mesh.setScale(Tween.linear(timer.elapsed, 1, -1, timer.duration));
            }
        });
    }

    override public function onResize() {
        super.onResize();
        bg_tile.setSize(s2d.width, s2d.height);
    }
}