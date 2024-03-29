import java.util.PriorityQueue;
import java.util.BitSet;

float scale = 14;
int size_param = 24; //indicates the size of the map
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
  for (int i = 0; i < 14; i++) {
    while (!tattoo.q.isEmpty()) {
      Point p = tattoo.q.poll();
      if (!p.inBounds()) continue;
      if (tattoo.occupied.get(p.id())) continue;
      tattoo.occupied.set(p.id());
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
  int radius() {
    return (abs(q) + abs(r) + abs(q + r))/2;
  }
  int id() {
    if ((q == 0) & (r == 0)) {
      return 0;
    }
    int L = radius();
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
  boolean inBounds() {
    return id()<mapsize;
  }
}

void gradLine(Point p) {
  PVector p1 = p.toScreenSpace();
  PVector p2 = p.parent.toScreenSpace();
  PVector v = PVector.sub(p2, p1);
  int increment = 2;
  for (int i=0; i<scale; i+=increment) {
    float sw = map(i, 0, scale, weight(p.age), weight(p.age-1));
    strokeWeight(sw);
    line(p1.x*scale+v.x*i, p1.y*scale+v.y*i, p1.x*scale+v.x*(i+increment), p1.y*scale+v.y*(i+increment));
  }
}

float priority(Point p) {
  float randomness = 1.0;
  float age_factor = 0.4;
  //float id_contribution = (id(p) % 10) * 10.0;
  float id_contribution = (p.id() % 50 < 25 ? 1 : 0) * 0.0;
  float direction_contribution = (p.parent != null && abs(p.q - p.parent.q) == 1 && p.r - p.parent.r == 0 ? 1 : 0) * 0.0;
  float radius_contribution = p.radius() % 8 * -100;
  return id_contribution + random(randomness) + p.age * age_factor + direction_contribution + radius_contribution;
}

float weight(int age) {
  return 1+0.5*scale*exp(-pow(age, 2)/1000);
}
