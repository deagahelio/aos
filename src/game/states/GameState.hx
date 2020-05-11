package game.states;

using Safety;

import game.utils.Timer;
import game.utils.Tween;
import game.Block;
import hxd.Key;
import h2d.Tile;
import h2d.Bitmap;
import h3d.Vector;
import h3d.scene.fwd.DirLight;
import hxd.Res;

class GameState extends State implements IBoard {
    static var SPAWN_HEIGHT = 10;
    var bg_scene: h2d.Scene;
    var bg_tile: Tile;
    var bg: Bitmap;
    public var blocks: Array<Block> = [];
    var cam_dist: Float = 20;
    var cam_angle = {x: -1, y: -1};
    var cam_angle_real = {x: -1., y: -1.};
    var cam_angle_tween: Null<Timer>;
    var piece: Piece;
    var last_piece_color: Int;
    var fall_timer = new Timer(2, true);
    var fade_tween: Null<Timer>;

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

        for (x in -2...3) {
            for (y in -2...3) {
                blocks.push(new Block(s3d, x, y));
            }
        }

        last_piece_color = Std.random(7) + 2;
        piece = new Piece(this, s3d, 0, 0, SPAWN_HEIGHT, last_piece_color);

        s3d.camera.pos.z = 20;
        s3d.camera.target.z = 5;
    }
    
    override function update(dt: Float) {
        super.update(dt);

        function cycleCamAngle(times=1, tween=true) {
            var old_cam_angle = {x: cam_angle.x, y: cam_angle.y};

            for (_ in 0...times) {
                switch (cam_angle) {
                    case {x: -1, y: -1}: cam_angle.x = 1;
                    case {x:  1, y: -1}: cam_angle.y = 1;
                    case {x:  1, y:  1}: cam_angle.x = -1;
                    case {x: -1, y:  1}: cam_angle.y = -1;
                    default: throw "???";
                }
            }

            if (tween) {
                cam_angle_tween = new Timer(.25, false, null, function(timer) {
                    cam_angle_real.x = Tween.linear(timer.elapsed, old_cam_angle.x, cam_angle.x - old_cam_angle.x, timer.duration);
                    cam_angle_real.y = Tween.linear(timer.elapsed, old_cam_angle.y, cam_angle.y - old_cam_angle.y, timer.duration);
                });
            }
        }

        function offsetFromAngle() {
            switch (cam_angle) {
                case {x: -1, y: -1}: return {x:  1, y:  0};
                case {x:  1, y: -1}: return {x:  0, y:  1};
                case {x:  1, y:  1}: return {x: -1, y:  0};
                case {x: -1, y:  1}: return {x:  0, y: -1};
                default: throw "???";
            }
        }

        function angleIndex() {
            switch (cam_angle) {
                case {x: -1, y: -1}: return 0;
                case {x:  1, y: -1}: return 1;
                case {x:  1, y:  1}: return 2;
                case {x: -1, y:  1}: return 3;
                default: throw "???";
            }
        }

        if (Key.isPressed(Key.Q)) {
            cycleCamAngle();
        }
        if (Key.isPressed(Key.E)) {
            cycleCamAngle(3);
        }
        if (Key.isDown(Key.CTRL)) {
            var index = angleIndex();
            var dirs = [0, 2, 1, 3];
            if (Key.isPressed(Key.NUMPAD_7)) piece.rotate(dirs[(0 + index) % 4]);
            if (Key.isPressed(Key.NUMPAD_8)) piece.rotate(dirs[(1 + index) % 4]);
            if (Key.isPressed(Key.NUMPAD_5)) piece.rotate(dirs[(2 + index) % 4]);
            if (Key.isPressed(Key.NUMPAD_4)) piece.rotate(dirs[(3 + index) % 4]);
        } else {
            if (Key.isPressed(Key.NUMPAD_7)) {
                var offset = offsetFromAngle();
                piece.move(offset.x, offset.y, 0);
            }
            if (Key.isPressed(Key.NUMPAD_8)) {
                cycleCamAngle(1, false);
                var offset = offsetFromAngle();
                cycleCamAngle(3, false);
                piece.move(offset.x, offset.y, 0);
            }
            if (Key.isPressed(Key.NUMPAD_5)) {
                cycleCamAngle(2, false);
                var offset = offsetFromAngle();
                cycleCamAngle(2, false);
                piece.move(offset.x, offset.y, 0);
            }
            if (Key.isPressed(Key.NUMPAD_4)) {
                cycleCamAngle(3, false);
                var offset = offsetFromAngle();
                cycleCamAngle(1, false);
                piece.move(offset.x, offset.y, 0);
            }
        }
        if (Key.isPressed(Key.F4)) {
            reset();
        }

        s3d.camera.pos.x = Math.sin(time) + cam_dist * cam_angle_real.x;
        s3d.camera.pos.y = Math.cos(time) + cam_dist * cam_angle_real.y;
        if (cam_angle_tween != null) cam_angle_tween.sure().update(dt);
        if (fade_tween != null) fade_tween.sure().update(dt);

        if (Key.isDown(Key.NUMPAD_0)) fall_timer.elapsed += dt * 7;
        if (fall_timer.update(dt))
            if (piece.move(0, 0, -1))
                nextPiece();

        trace(piece.blocks);
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
    }

    override function render(e: h3d.Engine) {
        bg_scene.render(e);
        super.render(e);
    }

    function reset() {
        if (fade_tween != null) return;

        fade_tween = new Timer(.5, false, function(timer) {
            for (block in blocks.concat(piece.blocks).concat(piece.ghost_blocks)) {
                block.mesh.remove();
            }

            blocks = [];
            for (x in -2...3) {
                for (y in -2...3) {
                    blocks.push(new Block(s3d, x, y, 0, 0));
                }
            }

            piece = new Piece(this, s3d, 0, 0, SPAWN_HEIGHT, Std.random(7) + 2);
            last_piece_color = piece.color;
            fall_timer.reset();

            cam_angle = {x: -1, y: -1};
            cam_angle_real = {x: -1., y: -1.};
            cam_angle_tween = null;

            fade_tween = new Timer(.5, false, function(_) {
                fade_tween = null;
            }, function(timer) {
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