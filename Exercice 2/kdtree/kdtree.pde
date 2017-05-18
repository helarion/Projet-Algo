
import java.util.Arrays;
import java.util.Comparator;
import java.util.Locale;

  KdTree kd_tree;
  Point[] points;

  public void setup() {
    size(900, 700, P2D);
    frameRate(100);
    initPoints(200);
  }
  
  void initPoints(int num_points){
    num_points = Math.max(1, num_points);
    
    float o = 40;
    randomSeed(10);
    points = new Point[num_points];
    for(int i = 0; i < points.length; i++){
      points[i] = new Point(random(o,width-o),random(o,height-o));
    }

    kd_tree = new KdTree(points);
}

  public void draw() {
    
    background(255);
    
    kd_tree.draw(this.g, !keyPressed, true,  0, 0, width, height);
  }

  public static class Point{
    public float x, y;

    public Point(float x, float y){
      this.x = x;
      this.y = y;
    }
  }
  
  public static class KdTree{

    int max_depth = 0;
    KdTree.Node root;
    
    public KdTree(Point[] points){
      max_depth = (int) Math.ceil( Math.log(points.length) / Math.log(2) );

      build( root = new KdTree.Node(0) , points);
      
    }
  
    private final static Quicksort quick_sort = new Quicksort();
    
    private void build(final KdTree.Node node, final Point[] points){
      
      final int e = points.length;
      final int m = e>>1;

      if( e > 1 ){
        int depth = node.depth;
        quick_sort.sort(points, depth&1);
 
        build( (node.L = new Node(++depth)), copy(points, 0, m));
        build( (node.R = new Node(  depth)), copy(points, m, e));
      }
      node.pnt = points[m];
    }
    
    private final static Point[] copy(final Point[] src, final int a, final int b){
      final Point[] dst = new Point[b-a]; 
      System.arraycopy(src, a, dst, 0, dst.length);
      return dst;
    }
    
    public int numFeuilles(KdTree.Node n, int num_Feuilles){
      if( n.isFeuille() ){
        return num_Feuilles+1;
      } else {
        num_Feuilles = numFeuilles(n.L, num_Feuilles);
        num_Feuilles = numFeuilles(n.R, num_Feuilles);
        return num_Feuilles;
      }
    }
       
    public void draw(PGraphics g, boolean points, boolean planes, float x_min, float y_min, float x_max, float y_max){
      if( planes ) drawPlanes(g, root, x_min, y_min, x_max, y_max);
      if( points ) drawPoints(g, root);
    }
    
    public void drawPlanes(PGraphics g, KdTree.Node node, float x_min, float y_min, float x_max, float y_max ){
      if( node != null ){
        Point pnt = node.pnt;
        if( (node.depth&1) == 0 ){
          drawPlanes(g, node.L, x_min, y_min, pnt.x, y_max);
          drawPlanes(g, node.R, pnt.x, y_min, x_max, y_max);
          drawLine  (g, node,   pnt.x, y_min, pnt.x, y_max);
        } else {
          drawPlanes(g, node.L, x_min, y_min, x_max, pnt.y);
          drawPlanes(g, node.R, x_min, pnt.y, x_max, y_max); 
          drawLine  (g, node,   x_min, pnt.y, x_max, pnt.y);
        }
      }
    }
    
    void drawLine(PGraphics g, KdTree.Node node, float x_min, float y_min, float x_max, float y_max){
      float dnorm = (node.depth)/(float)(max_depth+1);
      g.stroke(0,255,0);
      g.strokeWeight(2);
      g.line(x_min, y_min, x_max, y_max);
    }
    
    public void drawPoints(PGraphics g, KdTree.Node node){
      if( node.isFeuille() ){
        g.strokeWeight(2);
        g.stroke(0);
        g.fill(0);
        g.ellipse(node.pnt.x,node.pnt.y, 4, 4); 
      } else {
        drawPoints(g, node.L);
        drawPoints(g, node.R);
      }
    }
    
    public static class NN{
      Point pnt_in = null;
      Point pnt_nn = null;
      float min_sq = Float.MAX_VALUE;
      
      public NN(Point pnt_in){
        this.pnt_in = pnt_in;
      }
      
      void update(Node node){
        
        float dx = node.pnt.x - pnt_in.x;
        float dy = node.pnt.y - pnt_in.y;
        float cur_sq = dx*dx + dy*dy;

        if( cur_sq < min_sq ){
          min_sq = cur_sq;
          pnt_nn = node.pnt;
        }
      }
      
    }
    
    public NN getNN(Point point){
      NN nn = new NN(point);
      getNN(nn, root);
      return nn;
    }
    
    public NN getNN(NN nn, boolean reset_min_sq){
      if(reset_min_sq) nn.min_sq = Float.MAX_VALUE;
      getNN(nn, root);
      return nn;
    }
    
    private void getNN(NN nn, KdTree.Node node){
      if( node.isFeuille() ){
        nn.update(node);
      } else {
        float dist_hp = planeDistance(node, nn.pnt_in); 

        getNN(nn, (dist_hp < 0) ? node.L : node.R);
        
        if( (dist_hp*dist_hp) < nn.min_sq ){
          getNN(nn, (dist_hp < 0) ? node.R : node.L); 
        }
      }
    }
    
    private final float planeDistance(KdTree.Node node, Point point){
      if( (node.depth&1) == 0){
        return point.x - node.pnt.x;
      } else {
        return point.y - node.pnt.y;
      }
    }
    
    
    public static class Node{
      int depth;
      Point pnt;
      Node L, R;
      
      public Node(int depth){
        this.depth = depth;
      }
      boolean isFeuille(){
        return (L==null) | (R==null); // actually only one needs to be teste for null.
      }
    }
    
  }
    
  public static final class SortX implements Comparator<Point>{
    public int compare(final Point a, final Point b) {
      return (a.x < b.x) ? -1 : ((a.x > b.x)? +1 : 0);
    }
  }
  public static final class SortY implements Comparator<Point>{
    public int compare(final Point a, final Point b) {
      return (a.y < b.y) ? -1 : ((a.y > b.y)? +1 : 0);
    }
  }
 
  public static class Quicksort  {
    private int dim = 0;
    private Point[] points;
    private Point points_t_;
    
    public void sort(Point[] points, int dim) {
      if (points == null || points.length == 0) return;
      this.points = points;
      this.dim = dim;
      quicksort(0, points.length - 1);
    }

    private void quicksort(int bas, int haut) {
      int i = bas, j = haut;
      Point pivot = points[bas + ((haut-bas)>>1)];

      while (i <= j) {
        if( dim == 0 ){
          while (points[i].x < pivot.x) i++;
          while (points[j].x > pivot.x) j--;
        } else {
          while (points[i].y < pivot.y) i++;
          while (points[j].y > pivot.y) j--;
        }
        if (i <= j)  echange(i++, j--);
      }
      if (bas <  j) quicksort(bas,  j);
      if (i < haut) quicksort(i, haut);
    }

    private void echange(int i, int j) {
      points_t_ = points[i];
      points[i] = points[j];
      points[j] = points_t_;
    }
  }