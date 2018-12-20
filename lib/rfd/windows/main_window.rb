# frozen_string_literal: true

module Rfd
  class MainWindow < Window
    attr_reader :current_index, :begy
    attr_writer :number_of_panes

    def initialize
      @begy = 5
      @current_index = 0
      @number_of_panes = 2
      super(window: Curses::Pad.new(Curses.lines - 7, Curses.cols - 2))
    end

    def newpad(items)
      clear
      columns = items.size / maxy + 1
      newx = width * (((columns - 1) / @number_of_panes + 1) * @number_of_panes)
      resize(maxy, newx) if newx != maxx

      draw_items_to_each_pane(items)
    end

    def display(page)
      noutrefresh(0, (Curses.cols - 2) * page, begy, 1, begy + maxy - 1, Curses.cols - 2)
    end

    def activate_pane(num)
      @current_index = num
    end

    def pane_index_at(y: nil, x: nil)
      (y >= begy) && (begy + maxy > y) && (x / width)
    end

    def width
      (Curses.cols - 2) / @number_of_panes
    end

    def max_items
      maxy * @number_of_panes
    end

    def draw_item(item, current: false)
      setpos(item.index % maxy, width * @current_index)
      attron(Curses.color_pair(item.color) | (current ? Curses::A_REVERSE : Curses::A_NORMAL)) do
        self << item.to_s
      end
    end

    def draw_items_to_each_pane(items)
      items.each_slice(maxy).each.with_index do |arr, col_index|
        arr.each.with_index do |item, i|
          setpos(i, width * col_index)
          attron(Curses.color_pair(item.color) | Curses::A_NORMAL) { self << item.to_s }
        end
      end
    end

    def toggle_mark(item)
      item.toggle_mark
    end
  end
end
