import java.util.Collections;
import java.util.Comparator;
import java.util.Map;

class Day07 extends DayBase {
    final int HandValueHighCard = 1;
    final int HandValueOnePair = 2;
    final int HandValueTwoPair = 3;
    final int HandValueThreeOfAKind = 4;
    final int HandValueFullHouse = 5;
    final int HandValueFourOfAKind = 6;
    final int HandValueFiveOfAKind = 7;
    final String[] HandValueNames = new String[] {
        "Worthless", "HighCard", "OnePair", "TwoPair", "ThreeOfAKind", "FullHouse", "FourOfAKind", "FiveOfAKind"
    };

    private Day07ParsingData parsingData;

    Day07() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        this.rankHands(this.parsingData.setA);
        long sum = this.getAnswer(this.parsingData.setA);
        println("Part 1: Sum of all winnings is " + sum);
    }

    void part2() {
        this.rankHands(this.parsingData.setB);
        long sum = this.getAnswer(this.parsingData.setB);
        println("Part 2: Sum of all winnings is " + sum);
    }

    void run() {
        println("Start parsing data");
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        if (this.parsingData.isCheckingHands) {
            this.checkHands(this.parsingData.setA);
            this.checkHands(this.parsingData.setB);
        }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void stepParsingInputData() {
        String input;

        for (int i = 0; i < 10; i++) {
            if (this.parsingData.inputLineIndex >= this.parsingData.inputLineCount) {
                this.parsingData.isParsingData = false;
                this.parsingData.isCheckingHands = true;
                println("Parsing complete, " + this.parsingData.inputLineIndex + " hands parsed");
                return;
            }

            input = this.parsingData.input[this.parsingData.inputLineIndex];
            this.parsingData.setA.hands[this.parsingData.inputLineIndex] = this.parseHand(input, this.parsingData.setA.joker);
            this.parsingData.setB.hands[this.parsingData.inputLineIndex] = this.parseHand(input, this.parsingData.setB.joker);
            this.parsingData.inputLineIndex++;
        }

        println("Parsing... " + this.parsingData.inputLineIndex + " hands parsed");
    }

    Day07Hand parseHand(String data, String joker) {
        String handString = data.substring(0, 5);
        Day07Card[] cards = new Day07Card[5];
        Day07Card card;
        String label;

        for (int i = 0; i < 5; i++) {
            label = handString.substring(i, i + 1);
            card = new Day07Card(label, this.getCardValue(label, joker));
            cards[i] = card;
            // println("Parsed card " + card.label + " with value " + card.value);
        }

        Day07Hand hand = new Day07Hand(this.parsingData.inputLineIndex, handString, cards, int(data.substring(6)));
        // println("Parsed hand " + this.parsingData.inputLineIndex + " '" + handString + "' with bid " + hand.bid);
        return hand;
    }

    int getCardValue(String label, String joker) {
        if (joker != null && label.equals(joker)) {
            return 1;
        }

        switch(label) {
            case "A": return 14;
            case "K": return 13;
            case "Q": return 12;
            case "J": return 11;
            case "T": return 10;
            default: break;
        }

        return int(label);
    }

    void checkHands(Day07Set set) {
        println("Set " + set.id + ": Checking hands");

        Day07Hand hand;
        ArrayList<Day07Hand> list;
        for (int i = 0; i < set.hands.length; i++) {
            hand = set.hands[i];
            this.evaluateHand(hand, set.joker);
            
            if (!set.groups.containsKey(hand.handValue)) {
                list = new ArrayList<Day07Hand>();
                set.groups.put(hand.handValue, list);
            } else {
                list = set.groups.get(hand.handValue);
            }

            // println("Set" + set.id + ": Hand " + hand.id + " '" + hand.handString + "' has value of " + hand.handValue + ": '" +
            //     this.HandValueNames[hand.handValue] + "' and is at index " + list.size() + " in it's group");
            list.add(hand);
        }
    }

    void evaluateHand(Day07Hand hand, String joker) {
        // println("Hand " + hand.id + " '" + hand.handString + "' getting evaluated");
        int highestValue = 0;
        Day07Card card;
        int val;
        
        for (int i = 0; i < hand.cards.length; i++) {
            card = hand.cards[i];
            if (!hand.counts.hasKey(card.label)) {
                val = 1;
            } else {
                val = hand.counts.get(card.label) + 1;
            }
            
            hand.counts.set(card.label, val);

            if (val > 1) {
                hand.groups.set(card.label, val);
            }
        }

        int highGroup = 0;
        int lowGroup = 0;

        if (hand.groups.size() > 0) {
            // println("Hand " + hand.id + " has " + hand.groups.size() + " card groups");

            for (String key : hand.groups.keys()) {
                if (key.equals(joker)) {
                    continue; // Skip jokers as they will boost the highest group only
                }

                val = hand.groups.get(key);
                // println("Hand " + hand.id + " has card group '" + key + "' of " + val);

                if (val >= highGroup) {
                    if (highGroup > 0 && lowGroup == 0) {
                        // println("Hand " + hand.id + " low card group set to old high group " + val);
                        lowGroup = highGroup;
                    }
                    // println("Hand " + hand.id + " high card group set to " + val);
                    highGroup = val;
                } else if (lowGroup == 0 || (lowGroup > 0 && lowGroup > val)) {
                    // println("Hand " + hand.id + " low card group set to " + val);
                    lowGroup = val;
                }
            }

            if (joker != null && hand.counts.hasKey(joker)) {
                val = hand.counts.get(joker);
                if (val < 5) {
                    // Ensure 4 jokers and one normal card is correctly evaluated
                    highGroup = max(this.HandValueHighCard, highGroup);
                }
                // println("Hand " + hand.id + " has " + val + " jokers, boosting highest group from " + highGroup + " to " + (val + highGroup));
                highGroup += val;
            }

            hand.handValue = this.calculateHandValue(lowGroup, highGroup);
        } else {
            // println("Hand " + hand.id + " has no card groups");

            if (joker != null && hand.counts.hasKey(joker)) {
                val = hand.counts.get(joker);
                highGroup = val + 1;
                // println("Hand " + hand.id + " has " + val + " jokers, boosting hand to group of " + highGroup);
            }

            hand.handValue = this.calculateHandValue(lowGroup, highGroup);;
        }
    }

    int calculateHandValue(int lowGroup, int highGroup) {
        if (lowGroup > 0) {
            if (highGroup == 2) {
                return this.HandValueTwoPair;
            }
            if (highGroup == 3) {
                return this.HandValueFullHouse;
            }
        } else {
            if (highGroup == 2) {
                return this.HandValueOnePair;
            }
            if (highGroup == 3) {
                return this.HandValueThreeOfAKind;
            }
            if (highGroup == 4) {
                return this.HandValueFourOfAKind;
            }
            if (highGroup == 5) {
                return this.HandValueFiveOfAKind;
            }
        }

        return this.HandValueHighCard;
    }

    void rankHands(Day07Set set) {
        // println("Set " + set.id + ": Ranking hands");
        int rankIndex = 0;
        
        ArrayList<Day07Hand> list;
        Day07Hand hand;
        int i, k;

        for (i = this.HandValueHighCard; i <= this.HandValueFiveOfAKind; i++) {
            if (!set.groups.containsKey(i)) {
                // println("Set " + set.id + ": Nothing found in win group " + i + " '" + this.HandValueNames[i] + "'");
                continue;
            }

            list = set.groups.get(i);
            if (list.size() == 0) {
                // println("Set " + set.id + ": Empty list found for win group " + i + " '" + this.HandValueNames[i] + "'!");
                continue;
            }

            // println("Set " + set.id + ": Sorting win group " + i + " '" + this.HandValueNames[i] + "' list of " + list.size() + " hands");

            Collections.sort(list, new Comparator<Day07Hand>() {
                public int compare(Day07Hand a, Day07Hand b) {
                    int val;
                    Day07Card x, y;

                    for (int i = 0; i < a.handString.length(); i++) {
                        x = a.cards[i];
                        y = b.cards[i];
                        val = Integer.compare(x.value, y.value);

                        if (val != 0) {
                            // if (val > 0) {
                            //     println("Set " + set.id + ": Hand " + a.id + " '" + a.handString + "' is greater than Hand " + b.id + " '" + b.handString + "' at card[" + i + "]!");
                            // } else {
                            //     println("Set " + set.id + ": Hand " + a.id + " '" + a.handString + "' is less than Hand " + b.id + " '" + b.handString + "' at card[" + i + "]!");
                            // }
                            return val;
                        }
                    }

                    // println("Set " + set.id + ": Hand " + a.id + " '" + a.handString + "' and " + b.id + "'" + b.handString + "' are equal!");
                    return 0;
                }
            });

            for (k = 0; k < list.size(); k++) {
                hand = list.get(k);
                hand.rank = rankIndex + k + 1;
                // println("Set " + set.id + ": Hand " + hand.id + " '" + hand.handString + "' is at rank " + hand.rank + "!");
            }

            rankIndex += list.size();
        }

        // println("Set " + set.id + ": All hands ranked");
    }

    long getAnswer(Day07Set set) {
        long sum = 0;
        int value;
        Day07Hand hand;

        for (int k = 0; k < set.hands.length; k++) {
            hand = set.hands[k];
            value = hand.rank * hand.bid;
            sum += value;
            // println("Set " + set.id + ": Hand " + hand.id + " '" + hand.handString + "' is at rank " + hand.rank + " with bid " + hand.bid +
            //     ", resulting value is " + value);
        }

        return sum;
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day07ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class Day07ParsingData extends ParsingData {
    public Day07Set setA;
    public Day07Set setB;
    public boolean isCheckingHands;

    Day07ParsingData(String[] input) {
        super(input);
        this.setA = new Day07Set("A", input.length, null);
        this.setB = new Day07Set("B", input.length, "J");
        this.isCheckingHands = false;
    }
}

class Day07Set {
    public String id;
    public Day07Hand[] hands;
    public HashMap<Integer, ArrayList<Day07Hand>> groups;
    public String joker;

    Day07Set(String id, int size, String joker) {
        this.id = id;
        this.hands = new Day07Hand[size];
        this.groups = new HashMap<Integer,ArrayList<Day07Hand>>(size);
        this.joker = joker;
    }
}

class Day07Hand {
    public int id;
    public String handString;
    public int handValue;
    public int bid;
    public int rank;

    public Day07Card[] cards;
    public IntDict groups;
    public IntDict counts;

    Day07Hand(int id, String handString, Day07Card[] cards, int bid) {
        this.id = id;
        this.handString = handString;
        this.handValue = 0;
        this.bid = bid;
        this.rank = -1;
        this.cards = cards;
        this.groups = new IntDict();
        this.counts = new IntDict();
    }
}

class Day07Card {
    public String label;
    public int value;
    public boolean isJoker;

    Day07Card(String label, int value) {
        this.label = label;
        this.value = value;
        this.isJoker = false;
    }
}