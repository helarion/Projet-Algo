import java.util.Arrays;
import java.util.Comparator;
import java.util.Locale;

  PVector[] liste_PVectors;
  Arbre kd_tree;

  public void setup() 
  {
    init(100);
    size(800, 600);
  }
  
  void init(int nb_PVectors)
  {
      liste_PVectors = new PVector[nb_PVectors];
      for(int i = 0; i < liste_PVectors.length; i++){
        liste_PVectors[i] = new PVector(random(width),random(height));
      }
 
      kd_tree = new Arbre(liste_PVectors);
  }


   public static class Arbre
   {
      int max_profondeur = 0;
      Arbre.Node root;
      
      public Arbre(PVector[] PVectors)
      {
        max_profondeur = (int) Math.ceil( Math.log(PVectors.length) / Math.log(2) );
        build( root = new Arbre.Node(0) , PVectors);      
      }
  
      private final static TriABulle quick_sort = new TriABulle();
    
      private void build(final Arbre.Node node, final PVector[] PVectors)
      {      
        final int e = PVectors.length;
        final int m = e>>1;
  
        if( e > 1 )
        {
            int profondeur = node.profondeur;
            quick_sort.sort(PVectors, profondeur&1);
     
            build( (node.gauche = new Node(++profondeur)), copier(PVectors, 0, m));
            build( (node.droite = new Node(  profondeur)), copier(PVectors, m, e));
        }
        node.pnt = PVectors[m];
      }
    
      private final static PVector[] copier(final PVector[] src, final int a, final int b)
      {
        final PVector[] dst = new PVector[b-a]; 
        System.arraycopy(src, a, dst, 0, dst.length);
        return dst;
      }
      
      public int numFeuilles(Arbre.Node n, int num_Feuilles)
      {
          if( n.isFeuille() )
          {
            return num_Feuilles+1;
          } 
          else 
          {
            num_Feuilles = numFeuilles(n.gauche, num_Feuilles);
            num_Feuilles = numFeuilles(n.droite, num_Feuilles);
            return num_Feuilles;
          }
      }
         
      public void draw(PGraphics g, float xMin, float yMin, float xMax, float yMax)
      {
          drawPlanes(g, root, xMin, yMin, xMax, yMax);
          Points(g, root);
      }
      
      public void drawPlanes(PGraphics g, Arbre.Node node, float xMin, float yMin, float xMax, float yMax )
      {
          if( node != null )
          {
              PVector pnt = node.pnt;
              if( (node.profondeur&1) == 0 )
              {
                  drawPlanes(g, node.gauche, xMin, yMin, pnt.x, yMax);
                  drawPlanes(g, node.droite, pnt.x, yMin, xMax, yMax);
                  Lignes  (g, node,   pnt.x, yMin, pnt.x, yMax);
              } 
              else 
              {
                  drawPlanes(g, node.gauche, xMin, yMin, xMax, pnt.y);
                  drawPlanes(g, node.droite, xMin, pnt.y, xMax, yMax); 
                  Lignes  (g, node,   xMin, pnt.y, xMax, pnt.y);
              }
          }
      }
      
      void Lignes(PGraphics g, Arbre.Node node, float xMin, float yMin, float xMax, float yMax)
      {
          float dnorm = (node.profondeur)/(float)(max_profondeur+1);
          g.stroke(0,255,0);
          g.strokeWeight(2);
          g.line(xMin, yMin, xMax, yMax);
      }
      
      public void Points(PGraphics g, Arbre.Node node)
      {
          if( node.isFeuille() )
          {
              g.strokeWeight(4);
              g.stroke(255,0,0);
              g.fill(255,0,0);
              g.ellipse(node.pnt.x,node.pnt.y, 4, 4); 
          } 
          else 
          {
              Points(g, node.gauche);
              Points(g, node.droite);
          }
      }
      
      public static class Node
      {
          int profondeur;
          PVector pnt;
          Node gauche;
          Node droite;
          
          public Node(int profondeur)
          {
            this.profondeur = profondeur;
          }
          boolean isFeuille()
          {
              return (gauche==null) | (droite==null);
          }
      }  
  }
    
  public static final class TriABulleX implements Comparator<PVector>
  {
      public int compare(final PVector a, final PVector b) 
      {
        return (a.x < b.x) ? -1 : ((a.x > b.x)? +1 : 0);
      }
  }
  
  public static final class TriABulleY implements Comparator<PVector>
  {
      public int compare(final PVector a, final PVector b)
      {
        return (a.y < b.y) ? -1 : ((a.y > b.y)? +1 : 0);
      }
  }
 
  public static class TriABulle
  {
      private int dim = 0;
      private PVector[] PVectors;
      private PVector PVectors_t_;
      
      public void sort(PVector[] PVectors, int dim)
      {
          if (PVectors == null || PVectors.length == 0) return;
          this.PVectors = PVectors;
          this.dim = dim;
          TriABulle(0, PVectors.length - 1);
      }
  
      private void TriABulle(int bas, int haut)
      {
          int i = bas;
          int j = haut;
          PVector pivot = PVectors[bas + ((haut-bas)>>1)];
    
          while (i <= j)
          {
              if( dim == 0 )
              {
                  while (PVectors[i].x < pivot.x) i++;
                  while (PVectors[j].x > pivot.x) j--;
              } 
              else
              {
                  while (PVectors[i].y < pivot.y) i++;
                  while (PVectors[j].y > pivot.y) j--;
              }
              if (i <= j)  echange(i++, j--);
          }
          if (bas <  j) TriABulle(bas,  j);
          if (i < haut) TriABulle(i, haut);
      }
    
      private void echange(int i, int j)
      {
          PVectors_t_ = PVectors[i];
          PVectors[i] = PVectors[j];
          PVectors[j] = PVectors_t_;
      }
  }
  
  
  public void draw()
  {
    background(0);
    kd_tree.draw(this.g, 0, 0, width, height);
  }