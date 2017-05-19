import java.util.Arrays;
import java.util.Comparator;
import java.util.Locale;

  PVector[] liste_PVectors;
  Arbre arbre;

  public void setup() 
  {
    
    //// NOMBRE DE POINTS //////////////
    initialiser(100);
    size(800, 600);
  }
  
  void initialiser(int nb_PVectors)
  {
      liste_PVectors = new PVector[nb_PVectors];
      for(int i = 0; i < liste_PVectors.length; i++){
        liste_PVectors[i] = new PVector(random(width),random(height));
      }
 
      arbre = new Arbre(liste_PVectors);
  }

  public  class Noeud
      {
          int profondeur;
          PVector pointProche;
          Noeud gauche;
          Noeud droite;
          
          public Noeud(int profondeur)
          {
            this.profondeur = profondeur;
          }
          boolean isBranche()
          {
              return (gauche==null) | (droite==null);
          }
      }  

   public  class Arbre
   {
      int max_profondeur = 0;
      Noeud racine;
      
      public Arbre(PVector[] PVectors)
      {
        max_profondeur = (int) Math.ceil( Math.log(PVectors.length) / Math.log(2) );
        creer( racine = new Noeud(0), PVectors);      
      }
  
      private   TriABulle triABulle = new TriABulle();
    
      private void creer( Noeud Noeud,  PVector[] PVectors)
      {      
         int e = PVectors.length;
         int m = e>>1;
  
        if( e > 1 )
        {
            int profondeur = Noeud.profondeur;
            triABulle.sort(PVectors, profondeur&1);
     
            creer( (Noeud.gauche = new Noeud(++profondeur)), copier(PVectors, 0, m));
            creer( (Noeud.droite = new Noeud(  profondeur)), copier(PVectors, m, e));
        }
        Noeud.pointProche = PVectors[m];
      }
    
      private   PVector[] copier( PVector[] src,  int a,  int b)
      {
         PVector[] dst = new PVector[b-a]; 
        System.arraycopy(src, a, dst, 0, dst.length);
        return dst;
      }
      
      public int numBranches(Noeud n, int num_Branches)
      {
          if( n.isBranche() )
          {
            return num_Branches+1;
          } 
          else 
          {
            num_Branches = numBranches(n.gauche, num_Branches);
            num_Branches = numBranches(n.droite, num_Branches);
            return num_Branches;
          }
      }
         
      public void draw(PGraphics g, float xMin, float yMin, float xMax, float yMax)
      {
          affichage(g, racine, xMin, yMin, xMax, yMax);
          Points(g, racine);
      }
      
      public void affichage(PGraphics g, Noeud Noeud, float xMin, float yMin, float xMax, float yMax )
      {
          if( Noeud != null )
          {
              PVector pointProche = Noeud.pointProche;
              if( (Noeud.profondeur&1) == 0 )
              {
                  affichage(g, Noeud.gauche, xMin, yMin, pointProche.x, yMax);
                  affichage(g, Noeud.droite, pointProche.x, yMin, xMax, yMax);
                  Lignes(g, pointProche.x, yMin, pointProche.x, yMax);
              } 
              else 
              {
                  affichage(g, Noeud.gauche, xMin, yMin, xMax, pointProche.y);
                  affichage(g, Noeud.droite, xMin, pointProche.y, xMax, yMax); 
                  Lignes(g, xMin, pointProche.y, xMax, pointProche.y);
              }
          }
      }
      
      void Lignes(PGraphics g, float xMin, float yMin, float xMax, float yMax)
      {
          g.stroke(0,255,0);
          g.strokeWeight(2);
          g.line(xMin, yMin, xMax, yMax);
      }
      
      public void Points(PGraphics g, Noeud Noeud)
      {
          if( Noeud.isBranche() )
          {
              g.strokeWeight(4);
              g.stroke(255,0,0);
              g.fill(255,0,0);
              g.ellipse(Noeud.pointProche.x,Noeud.pointProche.y, 4, 4); 
          } 
          else 
          {
              Points(g, Noeud.gauche);
              Points(g, Noeud.droite);
          }
      }
      
      public class PlusProche
      {
          PVector source = null;
          PVector dest = null;
          float min = Float.MAX_VALUE;
          
          public PlusProche(PVector source)
          {
            this.source = source;
          }
          
          void update(Noeud Noeud)
          {
            float dx = Noeud.pointProche.x - source.x;
            float dy = Noeud.pointProche.y - source.y;
            float actuel = dx*dx + dy*dy;
    
            if( actuel < min && Noeud.pointProche.equals(source)==false){
              min = actuel;
              dest = Noeud.pointProche;
            }
          }
        
        }
    
        public PlusProche getPlusProche(PVector point)
        {
          PlusProche PlusProche = new PlusProche(point);
          getPlusProche(PlusProche, racine);
          return PlusProche;
        }
        
        public PlusProche getPlusProche(PlusProche PlusProche, boolean reset_min_sq)
        {
          if(reset_min_sq) PlusProche.min = Float.MAX_VALUE;
          getPlusProche(PlusProche, racine);
          return PlusProche;
        }
        
        private void getPlusProche(PlusProche PlusProche, Noeud Noeud)
        {
            if( Noeud.isBranche() )
            {
                PlusProche.update(Noeud);
            } 
            else 
            {
                float dist_hp = planeDistance(Noeud, PlusProche.source); 
                
                getPlusProche(PlusProche, (dist_hp < 0) ? Noeud.gauche : Noeud.droite);
                
                if( (dist_hp*dist_hp) < PlusProche.min )
                {
                    getPlusProche(PlusProche, (dist_hp < 0) ? Noeud.droite : Noeud.gauche); 
                }
            }
        }
        
        private final float planeDistance(Noeud Noeud, PVector point)
        {
            if( (Noeud.profondeur&1) == 0)
            {
                return point.x - Noeud.pointProche.x;
            } 
            else
            {
                return point.y - Noeud.pointProche.y;
            }
        }
   
  ////////////////////TROUVER LE POINT LE PLUS PROCHE DU PARAMETTRE //////////
      public void trouverPlusProche(int index)
      {
          PVector source=liste_PVectors[index];
          PVector dest = arbre.getPlusProche(source).dest;
          strokeWeight(5);
          stroke(255,0,255);
          line(source.x, source.y, dest.x, dest.y);
          
          float dis = dist( source.x, source.y, dest.x, dest.y);
          noFill();
          strokeWeight(2);
          fill(255,125,255,30);
          stroke(255,125,255);
          ellipse( source.x, source.y, dis*2, dis*2); 
      }
  }
 
 
 ///////////////// TRI DE TABLEAU //////////////////////////////
  public  class TriABulle
  {
      private int d = 0;
      private PVector[] PVectors;
      
      public void sort(PVector[] PVectors, int d)
      {
          if (PVectors == null || PVectors.length == 0) return;
          this.PVectors = PVectors;
          this.d = d;
          lancerTriABulle(0, PVectors.length - 1);
      }
      
      private void echange(int i, int j)
      {
          PVector temp = PVectors[i];
          PVectors[i] = PVectors[j];
          PVectors[j] = temp;
      }
      
      private void lancerTriABulle(int bas, int haut)
      {
          int i = bas;
          int j = haut;
          PVector pivot = PVectors[bas + ((haut-bas)>>1)];
    
          while (i <= j)
          {
              if( d == 0 )
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
          if (bas <  j) lancerTriABulle(bas,  j);
          if (i < haut) lancerTriABulle(i, haut);
      }
      for(int i=0;i<PVectors[i].length;i++){
        println("point n°"+i+":["+PVectors[i].x+"]["+PVectors[i].y+"] 
      }
  }
 ////////////////////////////////////////////////////////////////////// 
  
  public void draw()
  {
    background(0);
    arbre.draw(this.g, 0, 0, width, height);
    
    // paramettre = indice dans le tableau du point dont on veut connaitre le plus proche 
    arbre.trouverPlusProche(liste_PVectors.length/2);
  }