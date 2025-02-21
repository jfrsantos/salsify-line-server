require 'rails_helper'

describe FileService, type: :service do
  let(:filename) { 'sample.txt' }
  let(:filepath) { 'spec/fixtures' }
  let(:cache_path) { 'spec/cache' }
  let(:chunk_size) { 3 }
  let(:file_service) { FileService.new(filename, filepath, cache_path, chunk_size) }

  before(:each) do
    FileUtils.rm_rf(Dir.glob("#{cache_path}/*"))
  end

  describe '#get_line_text' do
    context 'when the line number is within the file' do
      it 'returns the line text' do
        expect(file_service.get_line_text(1)).to eq("THIS IS ASCII TEXT\n")
      end

      it 'reads from the correct chunk' do
        expect(file_service).to receive(:get_lines_naive).with(Rails.root.join(cache_path, 'sample_0.txt'), 0)
        file_service.get_line_text(1)

        expect(file_service).to receive(:get_lines_naive).with(Rails.root.join(cache_path, 'sample_1.txt'), 1)
        file_service.get_line_text(5)
      end

      it 'returns even if the line is empty at the end of the chunk' do
        expect(file_service.get_line_text(9)).to eq("\n")
      end
    end

    context 'when the line number is out of file' do
      it 'raises an error' do
        expect { file_service.get_line_text(11) }.to raise_error(LoadError)
      end
    end

    context 'when cache does not exist' do
      it 'creates the cache' do
        expect(File.exist?(Rails.root.join(cache_path, 'sample_0.txt'))).to be false
        file_service.get_line_text(1)
        expect(File.exist?(Rails.root.join(cache_path, 'sample_0.txt'))).to be true
      end

      it 'creates the correct number of chunks' do
        expect(Dir[Rails.root.join(cache_path, 'sample_*.txt')].length).to eq(0)
        file_service.get_line_text(1)
        expect(Dir[Rails.root.join(cache_path, 'sample_*.txt')].length).to eq(4)
      end
    end

    context 'when cache exists' do
      it 'does not create again' do
        file_service.get_line_text(1)
        expect(file_service).not_to receive(:create_chunks)
        file_service.get_line_text(1)
      end
    end
  end

  after do
    FileUtils.rm_rf(Dir.glob("#{cache_path}/*"))
  end
end
