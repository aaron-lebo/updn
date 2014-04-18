module ApplicationHelper
  def color
    a, b = rand(0..255), rand(0..255)
    "rgb(#{[a, b, rand((a > 128 || b > 128 ? 0 : 128)..255)].shuffle.join ','})" 
  end

def errors_for(object, message=nil)
  html = ""
  unless object.errors.blank?
    html << "<div class=\"flash-error\">\n"
    object.errors.full_messages.each do |error|
      html << error << "<br>"
    end
    html << "</div>\n"
  end

    raw(html)
  end

  def time_ago_in_words_label(*args)
    label_tag(nil, time_ago_in_words(*args),
      :title => args.first.strftime("%F %T %z"))
  end
end
