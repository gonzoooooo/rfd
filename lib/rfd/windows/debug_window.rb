# frozen_string_literal: true

module Rfd
  class DebugWindow < Window
    def initialize
      super(maxy: 1, maxx: 29, begy: 1, begx: Curses.cols - 30)
    end

    def debug(s)
      writeln(0, s.to_s)
      noutrefresh
    end
  end
end
