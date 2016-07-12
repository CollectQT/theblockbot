class ReportsController < ApplicationController
  before_action :set_report, only: [:approve, :deny, :show]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all.visible(current_user)
  end

  # GET /reports/1
  def show
  end

  # GET /reports/new
  def new
    if current_user
      @report = Report.new
    else
      redirect_to '/'
    end
  end

  # POST /reports
  # POST /reports.json
  def create
    if current_user
      @report = Report.parse(report_params['text'], current_user)

      respond_to do |format|
        if @report.save
          format.html { redirect_to '/reports/new', notice: 'Report was successfully created' }
        else
          format.html { render :new }
        end
      end
    else
      redirect_to '/'
    end
  end

  # POST /reposts/1
  def approve
    if @report.block_list.blocker? current_user
      @report.approve(current_user)

      respond_to do |format|
        format.html { redirect_to reports_url, notice: 'Report approved' }
      end
    else
      redirect_to :back
    end
  end

  # DELETE /reports/1
  def deny
    if @report.block_list.blocker? current_user
      @report.deny(current_user)

      respond_to do |format|
        format.html { redirect_to reports_url, notice: 'Report denied' }
      end
    else
      redirect_to :back
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.where(id: params[:id]).visible(current_user).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:text)
    end
end
