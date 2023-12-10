import java.util.HashSet;

class ViewRect {
    public int x;
    public int y;
    public int width;
    public int height;
    public int middleX;
    public int middleY;

    public ViewRect(int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.middleX = x + width / 2;
        this.middleY = y + height / 2;
    }
}

class Point2 {
    public int x;
    public int y;

    Point2(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

enum MapDirection {
    North, East, South, West
}

static class Directions {
    static MapDirection[] mapDirections = new MapDirection[] {
        MapDirection.North, MapDirection.East, MapDirection.South, MapDirection.West
    };

    static int getIndexOfMapDirection(MapDirection from) {
        if (from == MapDirection.North) { return 0; }
        if (from == MapDirection.East) { return 1; }
        if (from == MapDirection.South) { return 2; }
        return 3;
    }

    static MapDirection reverseMapDirection(MapDirection from) {
        if (from == MapDirection.North) { return MapDirection.South; }
        if (from == MapDirection.East) { return MapDirection.West; }
        if (from == MapDirection.South) { return MapDirection.North; }
        return MapDirection.East;
    }

    static int reverseMapDirection(int from) {
        return (from + mapDirections.length / 2) % mapDirections.length;
    }
}

static class Primes {
    private static boolean isInitialized;
    private static ArrayList<Integer> primesList;
    private static HashMap<Integer,Integer> primesMap;

    private static void initPrimes() {
        Primes.isInitialized = true;
        Primes.primesList = new ArrayList<Integer>();
        Primes.primesList.add(2);
        Primes.primesMap = new HashMap<Integer,Integer>();
        Primes.primesMap.put(2, 0);
        println("Initializing primes utility");
    }

    private static void addPrime(int prime) {
        Primes.primesMap.put(prime, Primes.primesList.size());
        Primes.primesList.add(prime);
    }

    public static int getKnownPrimeCount() {
        if (!Primes.isInitialized) { initPrimes(); }
        return Primes.primesList.size();
    }

    public static int getKnownPrimeAt(int index) {
        if (!Primes.isInitialized) { initPrimes(); }
        return index >= 0 && index < Primes.primesList.size() ? Primes.primesList.get(index) : 1;
    }

    public static int getLargestPrimeKnown() {
        if (!Primes.isInitialized) { initPrimes(); }
        return Primes.primesList.get(Primes.primesList.size() - 1);
    }

    public static int sievePrimesUpTo(int limit) {
        if (!Primes.isInitialized) { initPrimes(); }

        // Array size is half rounded up to ignore even numbers, zero position will be 2, the rest are 2*n+1
        int size = limit / 2 + limit % 2;
        int i, j, n, o;

        boolean[] array = new boolean[size];
        for (i = 0; i < size; i++) { array[i] = true; }

        int sqr = floor(sqrt(limit));
        i = Primes.primesList.size() - 1;
        int startOffset = i > 1 ? Primes.primesList.get(i) : 0;
        // println("Sieving up to square root " + sqr + " of limit " + limit + ", starting offset " + startOffset);

        // Note that position 0 is skipped since that is the prime number 2
        // Bitshift right to take half of odd number and rounding down gives the index

        for (n = 3; n <= sqr; n += 2) {
            // Get base starting point, either offset to an odd-numbered multiple of n, or simply n
            if (startOffset > 0) {
                if (startOffset % n == 0) {
                    o = startOffset + n;
                } else {
                    o = startOffset - (startOffset % n) + n;
                }
                if (o % 2 == 0) { o += n; }
            } else {
                o = n;
            }
            
            // Check if this base is already sieved away
            i = n >> 1;
            if (!array[i]) {
                // println("Base " + n + " value " + (2 * n + 1) + " at " + i + " was already sieved away");
                continue;
            }
            
            // Sieve away multiples of n, starting from offset or n^2 since
            // anything below is already done when starting without offset
            if (startOffset > 0) {
                j = o;

                // Also mark off square of base at the beginning for skipping multiples of it
                o = n;
                while (o < sqr) {
                    i = o >> 1;
                    array[i] = false;
                    // println("Sieving off " + o + " at " + i + ", multiple of base " + n);
                    o += n + n;
                }
            } else {
                j = n*n;
            }

            // println("Sieving away multiples of base " + n + " starting from " + j);

            while (j <= limit) {
                i = j >> 1;
                // println("Sieving off " + j + " at " + i + ", multiple of base " + n);
                array[i] = false;
                j+=n+n;
            }
        }

        int primeCount = 1;
        j = startOffset > 0 ? (startOffset + 1) >> 1 : 1;
        size = array.length;
        
        // print("Found prime numbers[2");
        for (i = j; i < size; i++) {
            if (array[i]) {
                n = 2 * i + 1;
                primeCount++;
                Primes.addPrime(n);
                // print("," + n);
            }
        }
        // println("]");

        return primeCount;
    }
    
    public static int getNextFrom(int from) {
        // println("Trying to find next prime from " + from);
        if (from <= 1) { return 2; }

        if (!Primes.isInitialized) { initPrimes(); }
        if (from > Primes.getLargestPrimeKnown()) {
            Primes.sievePrimesUpTo(from + floor(sqrt(from)));
        }

        int limit = from + floor(sqrt(from));
        int next = 3;
        int p = 1;

        int i, j;
        for (i = 0; i < limit; i++) {
            // Check number against all known primes
            for (j = 0; j < Primes.primesList.size(); j++) {
                p = Primes.primesList.get(j);

                if (next == p) {
                    // println("Next " + next + " equals known prime " + p + ", moving on");
                    break;
                }
                if (next % p == 0) {
                    // println(next + " is divisible by known prime of " + p + ", moving on");
                    p = next;
                    break;
                }
            }

            if (next > p && !Primes.primesMap.containsKey(next)) {
                // println("Next new prime from " + p + " is " + next);
                Primes.addPrime(next);
                p = next;
            }

            // Found what was asked
            if (next == p && next > from) {
                return next;
            }

            next += 2;
        }

        println("Unable to find next prime from " + from + " within " + limit + " steps of 2");
        return -1;
    }
}