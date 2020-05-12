package game;

import h3d.scene.Scene;
import hxd.Res;
import h3d.mat.Texture;
import h3d.scene.Mesh;
import h3d.prim.Cube;

class Block {
    static var primitive = new Cube(1, 1, 1);
    static var blocks = [];
    public var scene: Scene;
    public var pos: Point;
    public var x(get, set): Float;
    public var y(get, set): Float;
    public var z(get, set): Float;
    public var mesh: Mesh;
    public var color: Int;
    public var ghost: Bool;

    function get_x() return pos.x;
    function get_y() return pos.y;
    function get_z() return pos.z;
    function set_x(x) return (pos.x = x);
    function set_y(y) return (pos.y = y);
    function set_z(z) return (pos.z = z);

    public static function init() {
        primitive.addUVs();
        primitive.addNormals();

        var all_blocks = Res.blocks.getPixels();
        for (i in 0...9)
            blocks.push(Texture.fromPixels(all_blocks.sub(i * 32, 0, 32, 32)));
    }

    public function new(scene: Scene, x=0., y=0., z=0., color=0, ghost=false, ?mesh_override) {
        pos = new Point(x, y, z);
        this.scene = scene;
        this.color = color;
        this.ghost = ghost;

        if (mesh_override == null) {
            mesh = new Mesh(primitive, scene);
            mesh.setPosition(x, y, z);
            mesh.material.texture = blocks[color];
            mesh.material.texture.filter = Nearest;
            if (ghost)
                mesh.material.color.setColor(0x80FFFFFF);
            mesh.material.blendMode = Alpha;
            mesh.material.shadows = false;
        } else {
            mesh = mesh_override;
        }
    }

    public function clone() {
        return new Block(scene, x, y, z, color, ghost, mesh);
    }

    public function syncPos() {
        mesh.setPosition(x, y, z);
    }

    public function remove() {
        mesh.remove();
    }
}