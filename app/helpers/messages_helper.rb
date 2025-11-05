module MessagesHelper
  def urgency_class(message)
    case message.urgent
    when 3
      'list-group-item-danger'
    when 2
      'list-group-item-warning'
    when 1
      'list-group-item-info'
    else
      ''
    end
  end
end
