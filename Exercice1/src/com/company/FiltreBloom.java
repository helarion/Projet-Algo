package com.company;

import java.util.BitSet;

/**
 * Created by malherbe2 on 15/02/17.
 */
public class FiltreBloom {
    private final BitSet donnees;

    private final int masqueHachage;
    private static final int HASHAGE_MAX = 8;
    private static final long DEBUT_HACHAGE = 0xBB40E64DA205B064L;
    private final int numHachage;

    private static final long[] octets;
    private static final long HMULT = 7664345821815920749L;

    static {
        octets = new long[256 * HASHAGE_MAX];
        long h = 0x544B2FBACAAF1684L;
        for (int i = 0; i < octets.length; i++) {
            for (int j = 0; j < 31; j++)
                h = (h >>> 7) ^ h; h = (h << 11) ^ h; h = (h >>> 10) ^ h;
            octets[i] = h;
        }
    }

    private long hashCode(String s, int hcNo) {
        long h = DEBUT_HACHAGE;
        final long hmult = HMULT;
        final long[] ht = octets;
        int debut = 256 * hcNo;
        for (int len = s.length(), i = 0; i < len; i++) {
            char ch = s.charAt(i);
            h = (h * hmult) ^ ht[debut + (ch & 0xff)];
            h = (h * hmult) ^ ht[debut + ((ch >>> 8) & 0xff)];
        }
        return h;
    }

    public FiltreBloom(int noItems, int bitsPerItem, int numHachage) {
        int bitsRequired = noItems * bitsPerItem;
        if (bitsRequired >= Integer.MAX_VALUE) {
            throw new IllegalArgumentException("Filtre trop gros");
        }
        int logBits = 4;
        while ((1 << logBits) < bitsRequired)
            logBits++;
        if (numHachage < 1 || numHachage > HASHAGE_MAX)
            throw new IllegalArgumentException("nombre de has invalide");
        this.donnees = new BitSet(1 << logBits);
        this.numHachage = numHachage;
        this.masqueHachage = (1 << logBits) - 1;
    }

    public void add(String s) {
        for (int n = 0; n < numHachage; n++) {
            long hc = hashCode(s, n);
            int bitNo = (int) (hc) & this.masqueHachage;
            donnees.set(bitNo);
        }
    }

    public boolean contiens(String s) {
        for (int n = 0; n < numHachage; n++) {
            long hc = hashCode(s, n);
            int bitNo = (int) (hc) & this.masqueHachage;
            if (!donnees.get(bitNo)) return false;
        }
        return true;
    }

}
