module ApplicationHelper

  # ページごとの完全なタイトルを返す。
  def full_title(page_title = '')
    essential_title = "Sub Application from Selected Beginner Class"
    if page_title.empty?
      essential_title
    else
      page_title + " | " + essential_title
    end
  end
  
  
  
end