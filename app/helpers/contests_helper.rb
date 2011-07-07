module ContestsHelper
  def duration_between(from_date, to_date)
    hours, minutes, seconds, fracs = Date.send(
      :day_fraction_to_time, to_date.minus_with_duration(from_date))
    days = (hours/24).round
    hours = hours % 24
    return [
      pluralize(days, "day"),
      pluralize(hours, "hour"),
      pluralize(minutes, "minute"),
      pluralize(seconds, "second"),
    ].join(', ')
  end
end
