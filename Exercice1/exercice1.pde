import java.util.BitSet;

//0xBB40E64DA205B064L
//7664345821815920749L

 public void setup() 
  {
    exercice();
  }

  public class FiltreBloom 
  {
      private  BitSet donnees;
  
      private  int masqueHachage;
      
      // Nombre maximum de codes de hachage
      private int HACHAGE_MAX = 8;
      private long DEBUT_HACHAGE = 0x44859BF4896DL;
      private  int numHachage;
  
      private long[] octets;
      private long HMULT = 12640232513442L;
  
      private long codeHachage(String s, int hcNo)
      {
          long h = DEBUT_HACHAGE;
           long hmult = HMULT;
           long[] ht = octets;
          int debut = 256 * hcNo;
          for (int len = s.length(), i = 0; i < len; i++)
          {
              char ch = s.charAt(i);
              h = (h * hmult) ^ ht[debut + (ch & 0xff)];
              h = (h * hmult) ^ ht[debut + ((ch >>> 8) & 0xff)];
          }
          return h;
      }
  
      // constructeur
      public FiltreBloom(int noItems, int bitsPerItem, int numHachage)
      {
          // setup de la table de hachage
          octets = new long[256 * HACHAGE_MAX];
          long h = 0x544B2FBACAAF1684L;
          for (int i = 0; i < octets.length; i++) 
          {
              for (int j = 0; j < 31; j++)
              {
                  h = (h >>> 7) ^ h; h = (h << 11) ^ h; h = (h >>> 10) ^ h;
              }
              octets[i] = h;
          }
        
          // calcul du nombre de bits requis
          int bitsRequired = noItems * bitsPerItem;
          // gestion de dépassement
          if (bitsRequired >= Integer.MAX_VALUE) 
          {
              throw new IllegalArgumentException("Filtre trop gros");
          }
          
          int logBits = 4;
          while ((1 << logBits) < bitsRequired)
          {
              logBits++;
          }
          if (numHachage < 1 || numHachage > HACHAGE_MAX) throw new IllegalArgumentException("nombre de has invalide");
          
          // initialisation des données
          this.donnees = new BitSet(1 << logBits);
          this.numHachage = numHachage;
          this.masqueHachage = (1 << logBits) - 1;
      }
  
      // Ajoute un mot dans le filtre
      public void add(String s)
      {
          for (int n = 0; n < numHachage; n++)
          {
              // hachage du mot
              long hc = codeHachage(s, n);
              int bitNo = (int) (hc) & this.masqueHachage;
              // ajoute le mot haché aux données
              donnees.set(bitNo);
          }
      }
      
      // Teste si le filtre contient un mot
      public boolean contiens(String s)
      {
          // parcours les données
          for (int n = 0; n < numHachage; n++)
          {
              // hachage du mot
              long hc = codeHachage(s, n);
              int bitNo = (int) (hc) & this.masqueHachage;
              // si le mot ne correspond pas: return false
              if (!donnees.get(bitNo)) return false;
          }
          // sinon return true
          return true;
      }
  }

    // génération aléatoire de mots
    public String creerMot()
    {
        String mot="";
        // nombre aléatoire
        int num;
        String lettre;
        int taille=(int)(Math.random()*(8-4))+4;
       for(int i=0;i<taille;i++)
        {
            // génère un code ascii
            num=(int)(Math.random()*(122-97+1))+97;
            // attribue le code à un carractère
            lettre=Character.toString((char) num);
            // ajoute le carractère au mot
            mot+=lettre;
        }
        return mot;
    }
  
    // analyse des faux positifs etc.
    public void exercice()
    {
        //initialisation des compteurs
        int compteurMotsTest=0;
        int compteurFauxPositifs=0;
        
        // quantité de mots générée aléatoirement
        int nb=(int)(Math.random()*(50-15+1))+15;
        
        // création d'une liste de mots
        ArrayList<String> mots=new ArrayList<String>();
        for(int i=0; i<nb; i++)
        {
            // ajout d'un mot aléatoire
            mots.add(creerMot());
        }
        
        int n,t;
        for(n=1; n<=8; n++)
        {
            for(t=10;t<=20;t++)
            {
                // création d'un filtre
                FiltreBloom fb=new FiltreBloom((int)(Math.pow(2,t)),8,n);
                for(int i=0; i<nb; i++)
                {
                    //ajout de la liste de mot dans le filtre
                    fb.add(mots.get(i));
                }
                
                // test sur 20000 unités
                for(int k=1;k<20000;k++)
                {
                    // génération de mot aléatoire
                    String mot=creerMot();
                    System.out.print("Mot ajouté: "+mot);
                    // teste si le mot généré n'existe pas déja dans la liste
                    if(!mots.contains(mot))
                    {
                        System.out.println(" non présent initialement ");
                        compteurMotsTest++;
                        // teste si le mot existe déja dans le filtre
                        if(fb.contiens(mot))
                        {
                            System.out.println("présent dans le filtre ");
                            compteurFauxPositifs++;
                        }
                    }
                    System.out.println("");
                }           
            }
            // -----------   AFFICHAGE ---------------------------
                System.out.println("Taille du filtre: "+(int)(Math.pow(2,t)));
                System.out.println("Nombre de fonctions: "+n);
                System.out.println("Nombre de mots testés: "+compteurMotsTest);
                System.out.println("Nombre de faux positifs: "+compteurFauxPositifs);
                
                // calcul du taux
                double tauxFauxPositif=compteurFauxPositifs;
                tauxFauxPositif/=compteurMotsTest;
                tauxFauxPositif*=100;
                System.out.println("Taux de faux positifs: "+tauxFauxPositif+" %");
        }
    }