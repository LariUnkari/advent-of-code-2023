class Day04Visual extends DayVisualPageView {
    private int cardWidth = 124;
    private int cardHeight = 106;
    private color cardBorderColor = color(255);
    private int cardTitleFontSize = 20;
    private int cardSetWidth = 18;
    private int cardSetHeight = 18;
    private int cardSetMargin = 7;
    private int cardSetPadding = 5;
    private color cardSetColorMatch = color(0, 255, 0);
    private color cardSetColorNoMatch = color(255, 0, 0);
    private int cardWinsFontSize = 20;
    private int cardPointsFontSize = 16;
    private int cardCopiesFontSize = 16;

    private int tableX;
    private int tableY;
    private int tableWidth;
    
    private int cardsPerRow;
    private int cardRowsPerPage;
    private int cardsPerPage;
    private int cardSetsPerRow;

    private Day04ParsingData parsingData;

    Day04Visual(ViewRect viewRect, Day04ParsingData parsingData) {
        super(viewRect);

        this.parsingData = parsingData;
        
        this.cardsPerRow = this.viewRect.width / this.cardWidth;
        this.cardRowsPerPage = this.viewRect.height / this.cardHeight;
        this.cardsPerPage = this.cardsPerRow * this.cardRowsPerPage;
        this.pageCount = this.parsingData.cards.length / this.cardsPerPage +
            (this.parsingData.cards.length % this.cardsPerPage > 0 ? 1 : 0);

        this.cardSetsPerRow = (this.cardWidth - 2 * this.cardSetMargin + this.cardSetPadding) / (this.cardSetWidth + this.cardSetPadding);

        this.tableWidth = this.cardsPerRow * this.cardWidth;
        this.tableX = this.viewRect.middleX - this.tableWidth / 2;
        this.tableY = this.viewRect.y;
    }

    void draw() {
        super.draw();

        int posX, posY, midX, rgtX, idX, idY, cubX, cubY, setX, setY, winX, winY, ptsX, ptsY, copX, copY;
        Day04Card card;
        int setRows, setCount, setIndex, setValue;

        int cardIndex = 0;

        for (int y = 0; y < this.cardRowsPerPage; y++) {
            posY = this.tableY + y * this.cardHeight;

            for (int x = 0; x < this.cardsPerRow; x++) {
                cardIndex = this.pageIndex * this.cardsPerPage + y * 10 + x;
                if (cardIndex >= this.parsingData.cardCount) {
                    break;
                }

                card = this.parsingData.cards[cardIndex];
                posX = this.tableX + x * this.cardWidth;
                midX = posX + this.cardWidth / 2;
                rgtX = posX + this.cardWidth;

                fill(0);
                stroke(cardBorderColor);
                strokeWeight(2);
                rect(posX + 2, posY + 2, cardWidth - 4, cardHeight - 4);

                idX = posX + 5;
                idY = posY + 5;

                fill(255);
                noStroke();
                textSize(this.cardTitleFontSize);
                textAlign(LEFT, TOP);
                text("Card " + card.id, idX, idY);

                setX = posX + this.cardSetMargin;
                setY = idY + this.cardTitleFontSize;

                setIndex = 0;
                setCount = card.setNumbers.length;
                setRows = setCount / this.cardSetsPerRow + (setCount % this.cardSetsPerRow > 0 ? 1 : 0);

                for (int r = 0; r < setRows; r++) {
                    for (int c = 0; c < this.cardSetsPerRow; c++) {
                        setIndex = r * this.cardSetsPerRow + c;
                        if (setIndex >= setCount) {
                            break;
                        }

                        cubX = setX + c * (this.cardSetWidth + this.cardSetPadding);
                        cubY = setY + r * (this.cardSetHeight + this.cardSetPadding);
                        setValue = card.setNumbers[setIndex];

                        fill(card.matches.containsKey(setValue) ? cardSetColorMatch : cardSetColorNoMatch);
                        rect(cubX, cubY, this.cardSetWidth, this.cardSetHeight);
                    }

                    if (setIndex >= setCount) {
                        break;
                    }
                }

                ptsX = idX;
                ptsY = setY + setRows * this.cardSetHeight + (setRows - 1) * this.cardSetPadding + this.cardSetMargin - 2;
                copX = idX;
                copY = ptsY + this.cardCopiesFontSize;

                fill(255);
                noStroke();
                textAlign(LEFT, TOP);
                textSize(this.cardPointsFontSize);
                text("Points", ptsX, ptsY);
                textSize(this.cardCopiesFontSize);
                text("Copies", copX, copY);
                textAlign(RIGHT, TOP);
                textSize(this.cardPointsFontSize);
                text(card.points, rgtX - ptsX + posX, ptsY);
                textSize(this.cardCopiesFontSize);
                text(card.copies, rgtX - copX + posX, copY);

                /*powY = idY + this.cardFontSize + 2;
                cubRX = idX + 18;
                cubGX = cubRX + 34;
                cubBX = cubGX + 34;
                hiX = idX + 2;
                hiY = cubY - 1;

                textAlign(CENTER, TOP);
                textSize(this.cardWinsFontSize);
                text("POWER  " + card.power, midX, powY);
                setY = cubY + this.cardCubesRowHeight + 2;*/
            }

            if (cardIndex >= this.parsingData.cardCount) {
                break;
            }
        }
    }

    void update(int x, int y) {
        super.update(x, y);

        if (this.parsingData.isParsingData &&
            this.parsingData.cardIndex + 1 > (this.pageIndex + 1) * this.cardsPerPage) {
            this.pageIndex++;
        }
    }
}