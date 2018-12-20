# frozen_string_literal: true

module Rfd
  class HeaderRightWindow < Window
    def initialize
      super(maxy: 2, maxx: 29, begy: 2, begx: Curses.cols - 30)
    end

    def draw_marked_items(count: 0, size: 0)
      writeln(0, %Q[#{"#{count}Marked".rjust(11)} #{size.to_s.reverse.gsub( /(\d{3})(?=\d)/, '\1,').reverse.rjust(16)}])
      noutrefresh
    end

    def draw_total_items(count: 0, size: 0)
      writeln(1, %Q[#{"#{count}Files".rjust(10)} #{size.to_s.reverse.gsub( /(\d{3})(?=\d)/, '\1,').reverse.rjust(17)}])
      noutrefresh
    end
  end
end
