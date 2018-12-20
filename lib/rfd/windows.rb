# frozen_string_literal: true

require "delegate"

module Rfd
  class Window < DelegateClass(Curses::Window)
    def self.draw_borders
      [[5, Curses.stdscr.maxx, 0, 0], [5, Curses.cols - 30, 0, 0], [Curses.stdscr.maxy - 5, Curses.stdscr.maxx, 4, 0]].each do |height, width, top, left|
        w = Curses.stdscr.subwin(height, width, top, left)
        w.bkgdset Curses.color_pair(Curses::COLOR_CYAN)
        w.box(0, 0)
        w.close
      end
    end

    def initialize(maxy: nil, maxx: nil, begy: nil, begx: nil, window: nil)
      super window || Curses.stdscr.subwin(maxy, maxx, begy, begx)
    end

    def writeln(row, str)
      setpos(row, 0)
      clrtoeol
      self << str
      refresh
    end
  end
end

require_relative "./windows/command_line_window"
require_relative "./windows/debug_window"
require_relative "./windows/header_left_window"
require_relative "./windows/header_right_window"
require_relative "./windows/main_window"
