package game;

@:forward abstract Point(h3d.col.Point) from h3d.col.Point to h3d.col.Point {
    public inline function new(x, y, z) {
        this = new h3d.col.Point(x, y, z);
    }

    @:op(A + B) public function add(rhs) return this.add(rhs);
    @:op(A - B) public function sub(rhs) return this.sub(rhs);
    @:op(A * B) public function multiply(rhs: Float) return this.multiply(rhs);
    @:op(A == B) public function equals(rhs) return this.equals(rhs);

    @:op(A += B)
    public function add_assign(rhs) {
        this.x += rhs.x;
        this.y += rhs.y;
        this.z += rhs.z;
    }

    @:op(A -= B)
    public function sub_assign(rhs) {
        this.x -= rhs.x;
        this.y -= rhs.y;
        this.z -= rhs.z;
    }

    @:op(A *= B)
    public function multiply_assign(rhs) {
        this.x *= rhs.x;
        this.y *= rhs.y;
        this.z *= rhs.z;
    }
}