module CompaniesHelper
  def sort_link(column:, label_text:)
    if column == params[:column]
      link_to(label_text, filter_companies_path(column: column, direction: direction))
    else
      link_to(label_text, filter_companies_path(column: column, direction: 'asc'))
    end
  end

  def sort_direction_img
    tag.i(class: caret_direction_image)
  end

  def direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end

  def caret_direction_image
    case params[:direction]
    when 'asc'
      'bi-caret-up-fill'
    when 'desc'
      'bi-caret-down-fill'
    else
      nil
    end
  end
end
