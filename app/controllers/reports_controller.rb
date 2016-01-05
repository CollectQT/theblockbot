class ReportsController < ApplicationController
  before_action :set_report, only: [:approve, :deny, :show]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.where(processed: false)
  end

  # GET /reports/1
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.parse(report_params['text'], current_user)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created' }
      else
        format.html { render :new }
      end
    end
  end

  # POST /reposts/1
  def approve
    SendBlock.perform_async(@report.id, current_user.id)
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report approved' }
    end
  end

  # DELETE /reports/1
  def deny
    @report.update_attributes(processed: true)
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report denied' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:text)
    end
end
