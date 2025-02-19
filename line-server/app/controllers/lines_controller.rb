class LinesController < ApplicationController
  before_action :load_dependencies
  def get
    line = params[:line_number].to_i
    begin
      line_text = @file_service.get_line_text(line)
      render :plain => line_text, :status => :ok
    rescue LoadError
      render :plain => "OUT OF FILE\n", :status => :payload_too_large
    end
  end
  def load_dependencies(file_service = FileService.new('sample.txt', 3))
    @file_service ||= file_service
  end
end
