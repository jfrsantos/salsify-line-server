class LinesController < ApplicationController
  before_action :load_dependencies
  def get
    line = params[:line_number].to_i
    begin
      line_text = @file_service.get_line_text(line)
      render :json => {line: line_text}, :status => :ok
    rescue LoadError
      render :json => {error: "OUT OF FILE"}, :status => :payload_too_large
    end
  end

  def load_dependencies(file_service =
    FileService.new('sample.txt',
      Rails.application.config.files_path,
      Rails.application.config.cache_path,
      Rails.application.config.chunk_size))
    @file_service ||= file_service
  end
end
