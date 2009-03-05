module ProjectsHelper
  def link_to_project(project, text = nil, url_for_options = nil)
    link_to h(text || project.name), url_for_options || project
  end

  def period_to_sentence(filter, date_range, hours)
    plural = hours == 1 ? 'hour' : 'hours'
    filter = filter.to_sym if filter
    final = case filter
            when :daily
              date_range.first.strftime("%A, %b %d")
            when :monthly
              "for #{date_range.first.strftime("%B")}"
            when :'bi-weekly', :weekly
              "#{date_range.first.strftime("%B %d")}-#{date_range.last.strftime("%d")}"
            end
    %(#{plural} <span class="daterange">#{final}</span>)
  end

  def normalized_max(data)
    logger.warn "--------------\n#{data.inspect}"
    max = data.flatten.map { |d| d.to_f }.max.to_i
    ((max * 10 ** -1).ceil.to_f / 10 **-1).to_i
  end

  def csv(str)
    '"' + h(str).gsub('"', '""') + '"'
  end

  # this is a way of having a nice common interface whether you have
  # a single data set in hours  [1,2,3,3,1,15.2]
  # or multiple data sets [[1,2,3,3,1,5],[56,2,5,2,1]]
  def fudge_data_from(hours, chart_labels, filter)
    chart_data = []
    days = []
    total = 0
    if multi_chart?(hours) # array of arrays -- multi-chart
      hours.each do |hour|
        data = chart_data_for(chart_labels, filter, hour)
        chart_data << ((data.sum == 0 && filter == :weekly ) ? [0] : data)
      end # hours 
      days = []
      chart_data.each { |_set| _set.each_with_index { |day,i| days[i] = days[i].to_f + day.to_f }}
      total = days.flatten.sum
    else # single axis %>
      days = hours.map { |h| h[2] }
      chart_data = chart_data_for(chart_labels, filter, hours)
      chart_data = (chart_data.sum == 0 && filter == :weekly ) ? [0] : chart_data
      total = hours.sum { |h| h[2].to_f }
    end
    return days, chart_data, total, get_legends(hours)
  end

  def multi_chart?(hours)
    hours.inspect.starts_with? "[[["
  end

  def get_legends(hours)
    names = hours.map {|h| User.find(get_user_id(h)).login }
    names.join("|")
  end

  def get_user_id(hour)
    first_element = hour.first
    return first_element.first if first_element.respond_to? :first
    return first_element
  end

  def fudge_total_daily_hours(daily_hours)
    total = 0.0
    daily_hours.each do |entry|
      total = total + entry.flatten[2]
    end
    total
  end

end
