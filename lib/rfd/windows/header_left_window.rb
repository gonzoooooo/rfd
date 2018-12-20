# frozen_string_literal: true

module Rfd
  class HeaderLeftWindow < Window
    def initialize
      super(maxy: 3, maxx: Curses.cols - 32, begy: 1, begx: 1)
    end

    def draw_path_and_page_number(path: nil, current: 1, total: nil)
      writeln(0, %Q[Page: #{"#{current}/ #{total}".ljust(11)}  Path: #{path}])
      noutrefresh
    end

    def draw_current_file_info(current_file)
      draw_current_filename(current_file.full_display_name)
      draw_stat(current_file)
      noutrefresh
    end

    private
    def draw_current_filename(current_file_name)
      writeln(1, "File: #{current_file_name}")
    end

    def draw_stat(item)
      writeln(2, "      #{item.size_or_dir.ljust(13)}#{item.mtime} #{item.mode}")
    end
  end
end
