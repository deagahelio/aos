package game;

import game.utils.Tween;
import game.utils.Timer;
import h3d.scene.Scene;

class Piece {
    public var blocks: Array<Block> = [];
    public var ghost_blocks: Array<Block> = [];
    public var color: Int;
    public var scene: Scene;
    var last_blocks: Array<Block> = [];
    var tween_timer: Timer;
    var board: IBoard;

    public function new(board, scene, x, y, z, color) {
        this.scene = scene;
        this.color = color;
        this.board = board;

        blocks.push(new Block(scene, 0, 0, 0, color));

        for (i in 0...3) {
            var block = blocks[Std.random(i + 1)];
            var new_block = new Block(scene, block.x, block.y, block.z, color);

            while (true) {
                var pos = block.pos.clone();
                var side = Std.random(6);

                switch side {
                    case 0: pos.x++;
                    case 1: pos.x--;
                    case 2: pos.y++;
                    case 3: pos.y--;
                    case 4: pos.z++;
                    case 5: pos.z--;
                }

                var ok = true;
                for (block in blocks) {
                    if (block.x == pos.x && block.y == pos.y && block.z == pos.z) {
                        ok = false;
                        break;
                    }
                }

                if (ok) {
                    new_block.pos = pos;
                    break;
                }
            }

            blocks.push(new_block);
        }

        for (block in blocks) {
            block.pos += new Point(x, y, z);
            block.syncPos();
        }

        tween_timer = new Timer(.1, false, null, function(timer) {
            for (i in 0...blocks.length) {
                var block = blocks[i];
                var last_block = last_blocks[i];

                block.mesh.x = Tween.linear(timer.elapsed, last_block.x, block.x - last_block.x, .1);
                block.mesh.y = Tween.linear(timer.elapsed, last_block.y, block.y - last_block.y, .1);
                block.mesh.z = Tween.linear(timer.elapsed, last_block.z, block.z - last_block.z, .1);
            }
        }, true);

        updateGhost();
    }

    public function update(dt) {
        tween_timer.update(dt);
    }

    function updateGhost() {
        for (shadow in ghost_blocks)
            shadow.remove();

        ghost_blocks = [];

        var oZ = 0;
        while (!willCollide(0, 0, -1 + oZ) && oZ > -20)
            oZ--;

        if (oZ != 0)
            for (block in blocks)
                ghost_blocks.push(new Block(scene, block.x, block.y, block.z + oZ, color, true));
    }

    public function move(oX, oY, oZ): Bool {
        if (willCollide(oX, oY, 0))
            return false;

        if (willCollide(0, 0, oZ))
            return true;

        last_blocks = [];
        for (block in blocks) {
            last_blocks.push(block.clone());
            block.pos += new Point(oX, oY, oZ);
        }
        tween_timer.reset();
        
        updateGhost();
        return false;
    }

    public function rotate(dir, collide=true) {
        var temp;
        var anchor = blocks[0];
        var anchor_pos = anchor.pos.clone();

        last_blocks = [];
        for (block in blocks) {
            last_blocks.push(block.clone());
            block.pos -= anchor_pos;
            switch (dir) {
                case 0:
                    temp = block.x;
                    block.x = block.z;
                    block.z = -temp;
                case 1:
                    temp = block.x;
                    block.x = -block.z;
                    block.z = temp;
                case 2:
                    temp = block.y;
                    block.y = block.z;
                    block.z = -temp;
                case 3:
                    temp = block.y;
                    block.y = -block.z;
                    block.z = temp;
            }
            block.pos += anchor_pos;
            block.syncPos();
        }

        if (collide && willCollide(0, 0, 0)) {
            rotate(dir, false); rotate(dir, false); rotate(dir, false);
        } else {
            tween_timer.reset();
        }

        updateGhost();
    }

    function willCollide(oX, oY, oZ): Bool {
        var new_pos = [for (block in blocks) block.pos + new Point(oX, oY, oZ)];
        for (pos in new_pos)
            for (block in board.blocks)
                if (block.pos == pos)
                    return true;

        return false;
    }

    public function remove() {
        for (block in blocks.concat(ghost_blocks))
            block.remove();
    }
}