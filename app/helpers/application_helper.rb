module ApplicationHelper
  def formatted_date(date)
    date.strftime("%B %-d, %Y")
  end

  def display_height(value_in_meters)
    "#{format('%.1f', value_in_meters)} m"
  end

  def display_weight(value_in_kilograms)
    "#{format('%.1f', value_in_kilograms)} kg"
  end
end

