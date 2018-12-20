# frozen_string_literal: true

module Rfd
  class CommandLineWindow < Window
    def initialize
      super(maxy: 1, maxx: Curses.cols, begy: Curses.lines - 1, begx: 0)
    end

    def set_prompt(str)
      attron(Curses.color_pair(Curses::COLOR_WHITE) | Curses::A_BOLD) do
        writeln(0, str)
      end
    end

    def getstr_with_echo
      str = "".dup
      loop do
        case (c = Curses.getch)
        when 27
          raise Interrupt
        when 10, 13
          break
        else
          self << c
          refresh
          str << c
        end
      end
      str
    end

    def get_command(prompt: nil)
      startx = prompt ? prompt.size : 1
      setpos(0, startx)
      s = getstr_with_echo
      "#{prompt[1..-1] if prompt}#{s.strip}"
    end

    def show_error(str)
      attron(Curses.color_pair(Curses::COLOR_RED) | Curses::A_BOLD) do
        writeln(0, str)
      end
      noutrefresh
    end
  end
end
