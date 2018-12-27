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
      draw_cursor_with_row(str.size)
    end

    def getstr_with_echo(prompt, startx)
      str = "".dup
      loop do
        case (c = Curses.getch)
        when 27
          raise Interrupt
        when 10, 13
          break
        when 127
          next unless str.size > 0

          str.chop!
          setpos(0, startx + str.size)
          delch
          refresh
        else
          str << c
          attron(Curses.color_pair(Curses::COLOR_WHITE) | Curses::A_BOLD) do
            writeln(0, prompt + str)
          end
          draw_cursor_with_row(str.size)
          refresh
        end
      end
      str
    end

    def get_command(prompt: nil)
      startx = prompt ? prompt.size : 1
      setpos(0, startx)
      s = getstr_with_echo((prompt || ""), startx)
      "#{prompt[1..-1] if prompt}#{s.strip}"
    end

    def show_error(str)
      attron(Curses.color_pair(Curses::COLOR_RED) | Curses::A_BOLD) do
        writeln(0, str)
      end
      noutrefresh
    end

    private

      def draw_cursor_with_row(row)
        attron(Curses.color_pair(Curses::COLOR_WHITE) | Curses::A_REVERSE) do
          writeln(row, " ")
        end
      end
  end
end
