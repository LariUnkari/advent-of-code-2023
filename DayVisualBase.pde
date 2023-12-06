abstract class DayVisualBase {
    protected ViewRect viewRect;

    DayVisualBase(ViewRect viewRect) {
        this.viewRect = viewRect;
    }

    //abstract void init();

    abstract void draw();

    abstract void update(int x, int y);

    abstract void onMousePressed();
}