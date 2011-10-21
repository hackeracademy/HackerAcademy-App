module ApplicationHelper
  def shorten(string, length)
    if string.length > length
      return string[0..length-3]+"..."
    else
      return string
    end
  end
end
