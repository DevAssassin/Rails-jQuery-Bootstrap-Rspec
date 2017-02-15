pdf.font "Helvetica"
pdf.text "ScoutForce Report", :size => 12, :style => :bold

pdf.move_down(20)
logger = Logger.new("#{Rails.root}/log/my.log")
logger.info @report
items = @report.records.map do |result|
  logger.info result
  @report.export_fields(result)
end
logger.info items
items.unshift(@report.export_headers)

pdf.table(items) do |table|
  table.row_colors = ["FFFFFF","DDDDDD"]
  table.header = true
end

# pdf.move_down(20)
# pdf.text "Report created by: #{@report.user.name}", :size => 8
