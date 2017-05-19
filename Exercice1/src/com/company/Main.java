package com.company;

import java.util.ArrayList;

public class Main {

    public static String creerMot()
    {
        String mot="";
        int num;
        String lettre;
        int taille=(int)(Math.random()*(8-4))+4;
       for(int i=0;i<taille;i++)
        {
            num=(int)(Math.random()*(122-97+1))+97;
            lettre=Character.toString((char) num);
            mot+=lettre;
        }
        return mot;
    }

    public static void exercice()
    {
        int compteurMotsTest=0;
        int compteurFauxPositifs=0;
        int nb=(int)(Math.random()*(50-15+1))+15;
        ArrayList<String> mots=new ArrayList<String>();
        for(int i=0; i<nb; i++)
        {
            mots.add(creerMot());
        }
        for(int n=1; n<=8; n++)
        {
            for(int t=10;t<=20;t++)
            {
                FiltreBloom fb=new FiltreBloom((int)(Math.pow(2,t)),8,n);
                for(int i=0; i<nb; i++)
                {
                    fb.add(mots.get(i));
                }
                for(int k=1;k<20000;k++)
                {
                    String mot=creerMot();
                    if(!mots.contains(mot))
                    {
                        compteurMotsTest++;
                        if(fb.contiens(mot))
                        {
                            compteurFauxPositifs++;
                        }
                    }
                }
                System.out.println("Taille du filtre: "+(int)(Math.pow(2,t)));
                System.out.println("Nombre de fonctions: "+n);
                System.out.println("Nombre de mots testés: "+compteurMotsTest);
                System.out.println("Nombre de faux positifs: "+compteurFauxPositifs);
                double tauxFauxPositif=compteurFauxPositifs;
                tauxFauxPositif/=compteurMotsTest;
                tauxFauxPositif*=100;
                System.out.println("Taux de faux positifs: "+tauxFauxPositif+" %");
            }
        }
    }

    public static void main(String[] args) {
       exercice();
    }
}
