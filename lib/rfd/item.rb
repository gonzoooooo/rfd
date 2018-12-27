# frozen_string_literal: true
module Rfd
  class Item
    include Comparable
    attr_reader :name, :dir, :stat
    attr_accessor :index

    def initialize(path: nil, dir: nil, name: nil, stat: nil, window_width: nil)
      @path = path
      @dir = dir || File.dirname(path)
      @name = name || File.basename(path)
      @stat = stat
      @window_width = window_width
      @marked = false
      @stat = File.lstat(self.path) unless stat
    end

    def path
      @path ||= File.join(@dir, @name)
    end

    def basename
      @basename ||= File.basename(name, extname)
    end

    def extname
      @extname ||= File.extname(name)
    end

    def join(*ary)
      File.join(path, ary)
    end

    def full_display_name
      n = @name.dup
      n << " -> #{target}" if symlink?
      n
    end

    def display_name
      @display_name ||= begin
        n = full_display_name
        if mb_size(n) <= display_name_width
          n
        else
          if symlink?
            mb_left(n, display_name_width)
          else
            "#{mb_left(basename, display_name_width - extname.size)}…#{extname}"
          end
        end
      end
    end

    def color
      if symlink?
        Curses::COLOR_MAGENTA
      elsif hidden?
        Curses::COLOR_GREEN
      elsif directory?
        Curses::COLOR_CYAN
      elsif executable?
        Curses::COLOR_RED
      else
        Curses::COLOR_WHITE
      end
    end

    def size
      directory? ? 0 : stat.size
    end

    def size_with_unit
      return "0" if directory?

      if size < 1000
        "#{size} bytes"
      elsif size < 1_000_000
        "%.1f KB" % (size / 1000.to_f)
      elsif size < 1_000_000_000
        "%.1f MB" % (size / 1000_000.to_f)
      elsif size < 1_000_000_000_000
        "%.1f GB" % (size / 1000_000_000.to_f)
      elsif size < 1_000_000_000_000_000
        "%.1f TB" % (size / 1000_000_000_000.to_f)
      end
    end

    def size_or_dir
      directory? ? "<DIR>" : size_with_unit
    end

    def atime
      stat.atime.strftime("%Y-%m-%d %H:%M:%S")
    end

    def ctime
      stat.ctime.strftime("%Y-%m-%d %H:%M:%S")
    end

    def mtime
      stat.mtime.strftime("%Y-%m-%d %H:%M:%S")
    end

    def mode
      @mode ||= begin
        m = stat.mode
        ft = directory? ? "d" : symlink? ? "l" : "-"
        ret = [(m & 0700) / 64, (m & 070) / 8, m & 07].inject(ft) do |str, s|
          str += "#{s & 4 == 4 ? "r" : "-"}#{s & 2 == 2 ? "w" : "-"}#{s & 1 == 1 ? "x" : "-"}"
        end
        if m & 04000 != 0
          ret[3] = directory? ? "s" : "S"
        end
        if m & 02000 != 0
          ret[6] = directory? ? "s" : "S"
        end
        if m & 01000 == 512
          ret[-1] = directory? ? "t" : "T"
        end
        ret
      end
    end

    def directory?
      @directory ||= if symlink?
        begin
          File.stat(path).directory?
        rescue Errno::ENOENT
          false
        end
      else
        stat.directory?
      end
    end

    def symlink?
      stat.symlink?
    end

    def hidden?
      name.start_with?(".") && (name != ".") && (name != "..")
    end

    def executable?
      stat.executable?
    end

    def zip?
      @zip_ ||= begin
        if directory?
          false
        else
          File.binread(realpath, 4).unpack("V").first == 0x04034b50
        end
      rescue
        false
      end
    end

    def gz?
      @gz_ ||= begin
        if directory?
          false
        else
          File.binread(realpath, 2).unpack("n").first == 0x1f8b
        end
      rescue
        false
      end
    end

    def target
      File.readlink(path) if symlink?
    end

    def realpath
      @realpath ||= File.realpath(path)
    end

    def toggle_mark
      unless %w(. ..).include? name
        @marked = !@marked
        true
      end
    end

    def marked?
      @marked
    end

    def current_mark
      marked? ? "*" : " "
    end

    def mb_left(str, size)
      len = 0
      index = str.each_char.with_index do |c, i|
        break i if len + mb_char_size(c) > size
        len += mb_size c
      end
      str[0, index]
    end

    def mb_char_size(c)
      c == "…" ? 1 : c.bytesize == 1 ? 1 : 2
    end

    def mb_size(str)
      str.each_char.inject(0) { |l, c| l += mb_char_size(c) }
    end

    def mb_ljust(str, size)
      "#{str}#{" " * [0, size - mb_size(str)].max}"
    end

    def to_s
      if display_name_width > 0
        "#{current_mark}#{mb_ljust(display_name, display_name_width)}#{size_or_dir.rjust(13)}  #{mtime}"
      else
        "#{current_mark}#{mb_ljust(display_name, @window_width - 15)}#{size_or_dir.rjust(13)}"
      end
    end

    def to_str
      path
    end

    def <=>(o)
      if directory? && !o.directory?
        1
      elsif !directory? && o.directory?
        -1
      else
        name <=> o.name
      end
    end

    private

      def display_name_width
        current_mark_width = 1
        size_or_dir_width = 13
        margin_between_size_or_dir_and_mtime = 2
        mtime_width = 19
        right_margin = 1

        @window_width - (current_mark_width + size_or_dir_width + margin_between_size_or_dir_and_mtime + mtime_width + right_margin)
      end

  end
end
