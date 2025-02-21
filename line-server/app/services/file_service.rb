class FileService
  def initialize(filename, filepath, cache_path, chunk_size)
    @filename = filename
    @filepath = filepath
    @cache_path = cache_path
    @chunk_size = chunk_size
  end

  def get_line_text(line)
    line_index = line - 1
    file = Rails.root.join(filepath, filename)
    create_chunks(file, chunk_size) unless has_chunks?(file)
    get_lines_from_chunk(line_index)
  end

  private
  attr_reader :filename, :filepath, :cache_path, :chunk_size

  # This method reads the file line by line until it finds the desired line.
  # It is not efficient for high line number as every line until the desired one is read.
  def get_lines_naive(file, line_index)
    File.open(file).each_with_index do |file_line_text, index|
      if index == line_index
        return file_line_text
      end
    end
    raise LoadError
  end

  # This method reads the whole file into memory and returns the desired line.
  # It is not efficient for large files as it loads the whole file into memory.
  def get_lines_memory(file, line_index)
    lines = File.readlines(file)
    lines[line_index]
  end

  # Uses the naive approach but on smaller files that are split into chunks.
  # This method is more efficient for large files as it only reads the chunk that contains the desired line.
  def get_lines_from_chunk(line_index)
    chunk_filename = Rails.root.join(cache_path, chunk_filename(line_index/chunk_size))
    File.exist?(chunk_filename) ? get_lines_naive(chunk_filename, line_index % chunk_size) : raise(LoadError)
  end

  def has_chunks?(file)
    File.exist?(Rails.root.join(cache_path, chunk_filename(0)))
  end

  def create_chunks(input_file, chunk_size)
    base_output_file_path = Rails.root.join(cache_path)
    FileUtils.mkdir_p(base_output_file_path) # Ensure the directory exists

    File.open(input_file) do |file|
      file.each_slice(chunk_size).with_index do |lines, index|
        output_file_path = base_output_file_path.join(chunk_filename(index))
        write_file(output_file_path, lines)
      end
    end
  end

  def write_file(filename, lines)
    File.open(filename, 'w') do |out_file|
      lines.each_with_index do |line, line_index|
        out_file.puts(line)
      end
    end
  end

  def chunk_filename(index)
    chunk_filename = File.basename(filename, '.*')
    chunk_extension = File.extname(filename)
    "#{chunk_filename}_#{index}#{chunk_extension}"
  end
end
