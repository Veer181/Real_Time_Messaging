module MessagesHelper
  def urgency_class(message)
    case message.urgent
    when 3
      'table-danger'
    when 2
      'table-warning'
    when 1
      'table-info'
    else
      ''
    end
  end

  def urgency_color(message)
    case message.urgent
    when 3
      '#dc3545' # Red for High
    when 2
      '#ffc107' # Orange for Medium
    when 1
      '#0dcaf0' # Blue for Low
    else
      '#6c757d' # Grey for None
    end
  end

  def message_row_class(message)
    urgency_class = case message.urgent
                    when 3 then 'table-danger'
                    when 2 then 'table-warning'
                    when 1 then 'table-info'
                    else ''
                    end

    return urgency_class if urgency_class.present?

    if message.replies.any?
      'table-success-light'
    elsif message.read_at.present?
      'table-light'
    else
      ''
    end
  end

  def urgency_level(message)
    case message.urgent
    when 3
      'High'
    when 2
      'Medium'
    when 1
      'Low'
    else
      'No'
    end
  end
end
