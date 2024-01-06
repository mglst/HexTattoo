import java.util.PriorityQueue;
import java.util.BitSet;

float scale = 30;
int size_param = 7; //indicates the size of the map
int mapsize = size_param*(size_param+1)*3+1; 

void setup() {
  size(700, 700);
  reset();
  //frameRate(5);
}

void reset() {
  background(255);
  tattoo = new Tattoo();
}

void keyPressed() {
  if(key == 's'){
    save("tattoo"+hour()+minute()+second()+".png");
  }
  reset();
}

Tattoo tattoo;

class Tattoo{
  BitSet occupied;
  PriorityQueue<Point> q;
  Tattoo(){
    occupied = new BitSet(mapsize);
    q = new PriorityQueue<Point>();
    q.add(new Point(0, 0, null));
  }
}

void draw() {
  pushMatrix();
  translate(width*0.5, height*.5);
  for (int i = 0; i < 1; i++) {
    while (!tattoo.q.isEmpty()) {
      Point p = tattoo.q.poll();
      if (!inBounds(p)) continue;
      if (tattoo.occupied.get(id(p))) continue;
      tattoo.occupied.set(id(p));
      if (p.parent != null) {
        gradLine(p);
      }
      //for hex
      if(p.age % 2 == 0){
        tattoo.q.add(new Point(p.q, p.r - 1, p));
        tattoo.q.add(new Point(p.q + 1, p.r, p));
        tattoo.q.add(new Point(p.q - 1, p.r + 1, p));
      }else{
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

    priority = priority(this, q, r);
  }
  int compareTo(Point other) {
    if (priority < other.priority) return -1;
    return 1;
  }
  PVector toScreenSpace() {
    return new PVector(q + 0.5 * r, sqrt(3)/2 * r);
  }
}

void gradLine(Point p){
  PVector p1 = p.toScreenSpace();
  PVector p2 = p.parent.toScreenSpace();
  PVector v = PVector.sub(p2,p1);
  for (int i=0; i<scale; i+=5){
    float sw = map(i, 0, scale, weight(p.age), weight(p.age-1));
    strokeWeight(sw);
    line(p1.x*scale+v.x*i, p1.y*scale+v.y*i, p1.x*scale+v.x*(i+5), p1.y*scale+v.y*(i+5));
  }
  //int r = floor(p.y * 2 / sqrt(3));
  //int q = floor(p.x - 0.5 * r);
  //textSize(30);
  //fill(0);
  //text(r+","+q, p.x*scale+30, p.y*scale+20);
}

float priority(Point p, float x, float y){
  return (dist(0, 0, x, y)+random(1));
}

float weight(int age){
  return 1+0.5*scale*exp(-pow(age,2)/40);
}
