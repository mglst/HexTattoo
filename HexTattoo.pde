import java.util.PriorityQueue;
import java.util.BitSet;

float scale = 28;
int size_param = 12; //indicates the size of the map
int mapsize = size_param*(size_param+1)*3+1;
GridType gridType = GridType.Triangles;

void setup() {
  size(700, 700);
  pixelDensity(2);
  reset();
  //frameRate(5);
}

void reset() {
  background(255);
  tattoo = new Tattoo();
}

void keyPressed() {
  if (key == 's') {
    save("tattoo"+hour()+minute()+second()+".png");
  }
  reset();
}

Tattoo tattoo;

class Tattoo {
  BitSet occupied;
  PriorityQueue<Point> q;
  Tattoo() {
    occupied = new BitSet(mapsize);
    q = new PriorityQueue<Point>();
    q.add(new Point(0, 0, null));
  }
}

enum GridType {
  Triangles, Hexagons
}

void draw() {
  pushMatrix();
  translate(width*0.5, height*.5);
  for (int i = 0; i < 5; i++) {
    while (!tattoo.q.isEmpty()) {
      Point p = tattoo.q.poll();
      if (!inBounds(p)) continue;
      if (tattoo.occupied.get(id(p))) continue;
      tattoo.occupied.set(id(p));
      if (p.parent != null) {
        gradLine(p);
      }
      //for hex
      if (p.age % 2 == 0 || gridType == GridType.Triangles) {
        tattoo.q.add(new Point(p.q, p.r - 1, p));
        tattoo.q.add(new Point(p.q + 1, p.r, p));
        tattoo.q.add(new Point(p.q - 1, p.r + 1, p));
      }
      if (p.age % 2 == 1 || gridType == GridType.Triangles) {
        tattoo.q.add(new Point(p.q + 1, p.r - 1, p));
        tattoo.q.add(new Point(p.q, p.r + 1, p));
        tattoo.q.add(new Point(p.q - 1, p.r, p));
      }
      if (p.parent != null) break;
    }
  }
  popMatrix();
}

int id(Point p) {
  int r = p.r;
  int q = p.q;
  if ((q == 0) & (r == 0)) {
    return 0;
  }
  int L = (abs(q) + abs(r) + abs(q + r))/2;
  int n = 3 * L * (L - 1);
  if (q == L) {
    return n + 6 * L + r;
  }
  if (q + r == L) {
    return n + r;
  }
  if (r == L) {
    return n + L - q;
  }
  if (q == -L) {
    return n + 3 * L - r;
  }
  if (q + r == -L) {
    return n + 3 * L - r;
  }
  return n + 4 * L + q;
}

boolean inBounds(Point p) {
  return id(p)<mapsize;
}

class Point implements Comparable<Point> {
  int q, r;
  int age;
  Point parent;
  float priority;
  Point(int q, int r, Point parent) {
    this.q = q;
    this.r = r;
    this.parent = parent;
    if (parent == null) age = 0;
    else age = parent.age + 1;

    priority = priority(this);
  }
  int compareTo(Point other) {
    if (priority < other.priority) return -1;
    return 1;
  }
  PVector toScreenSpace() {
    return new PVector(q + 0.5 * r, sqrt(3)/2 * r);
  }
}

void gradLine(Point p) {
  PVector p1 = p.toScreenSpace();
  PVector p2 = p.parent.toScreenSpace();
  PVector v = PVector.sub(p2, p1);
  int increment = 4;
  for (int i=0; i<scale; i+=increment) {
    float sw = map(i, 0, scale, weight(p.age), weight(p.age-1));
    strokeWeight(sw);
    line(p1.x*scale+v.x*i, p1.y*scale+v.y*i, p1.x*scale+v.x*(i+increment), p1.y*scale+v.y*(i+increment));
  }
}

float priority(Point p) {
  return (dist(0, 0, p.q, p.r)+random(1));
}

float weight(int age) {
  return 1+0.5*scale*exp(-pow(age, 2)/100);
}
