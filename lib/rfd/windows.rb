# frozen_string_literal: true

require "delegate"

module Rfd
  class Window < DelegateClass(Curses::Window)
    def self.draw_borders
      header_height = 5
      header_right_width = 30
      header_rect = [header_height, Curses.stdscr.maxx, 0, 0]
      header_sub_rect = [header_height, Curses.cols - header_right_width, 0, 0]
      body_rect = [Curses.stdscr.maxy - header_height, Curses.stdscr.maxx, header_height - 1, 0]

      [header_rect, header_sub_rect, body_rect].each do |height, width, top, left|
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
