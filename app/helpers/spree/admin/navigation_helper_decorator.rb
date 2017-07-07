Spree::Admin::NavigationHelper.class_eval do
  #Override: Add disable_with option to prevent multiple request on consecutive clicks
  def button(text, icon_name = nil, button_type = 'submit', options={})
    if icon_name
      icon = content_tag(:span, '', class: "icon icon-#{icon_name}")
      text.insert(0, icon + ' ')
    end
    button_tag(text.html_safe, options.merge(type: button_type, class: "btn btn-primary #{options[:class]}", 'data-disable-with' => "#{ Spree.t(:saving) }..."))
  end
end
