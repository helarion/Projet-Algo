package com.company;

import java.util.BitSet;

/**
 * Created by malherbe2 on 15/02/17.
 */
public class FiltreBloom {
    private static final int MAX_HASHES = 8;
    private static final long[] byteTable;
    private static final long HSTART = 0xBB40E64DA205B064L;
    private static final long HMULT = 7664345821815920749L;
    private final BitSet data;
    private final int noHashes;
    private final int hashMask;

    static {
        byteTable = new long[256 * MAX_HASHES];
        long h = 0x544B2FBACAAF1684L;
        for (int i = 0; i < byteTable.length; i++) {
            for (int j = 0; j < 31; j++)
                h = (h >>> 7) ^ h; h = (h << 11) ^ h; h = (h >>> 10) ^ h;
            byteTable[i] = h;
        }
    }

    private long hashCode(String s, int hcNo) {
        long h = HSTART;
        final long hmult = HMULT;
        final long[] ht = byteTable;
        int startIx = 256 * hcNo;
        for (int len = s.length(), i = 0; i < len; i++) {
            char ch = s.charAt(i);
            h = (h * hmult) ^ ht[startIx + (ch & 0xff)];
            h = (h * hmult) ^ ht[startIx + ((ch >>> 8) & 0xff)];
        }
        return h;
    }

    public FiltreBloom(int noItems, int bitsPerItem, int noHashes) {
        int bitsRequired = noItems * bitsPerItem;
        if (bitsRequired >= Integer.MAX_VALUE) {
            throw new IllegalArgumentException("FIltre trop gros");
        }
        int logBits = 4;
        while ((1 << logBits) < bitsRequired)
            logBits++;
        if (noHashes < 1 || noHashes > MAX_HASHES)
            throw new IllegalArgumentException("nombre de has invalide");
        this.data = new BitSet(1 << logBits);
        this.noHashes = noHashes;
        this.hashMask = (1 << logBits) - 1;
    }

    public void add(String s) {
        for (int n = 0; n < noHashes; n++) {
            long hc = hashCode(s, n);
            int bitNo = (int) (hc) & this.hashMask;
            data.set(bitNo);
        }
    }

    public boolean contains(String s) {
        for (int n = 0; n < noHashes; n++) {
            long hc = hashCode(s, n);
            int bitNo = (int) (hc) & this.hashMask;
            if (!data.get(bitNo)) return false;
        }
        return true;
    }

}
