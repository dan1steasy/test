module DcHelper
  
  def cabinet_link_display(cabinets, use_ajax_links=false)
    cab_ctr = 0
    row_ctr = 0
    @rows = []
    cabinets.each do |cabinet| 
      # Print out a cabinet link. Once we have three, create a new row.
      row_ctr += 1 if cab_ctr % 3 == 0
      @rows[row_ctr] = [] if @rows[row_ctr].blank?
      @rows[row_ctr] << cabinet_link(cabinet, use_ajax_links)
      cab_ctr += 1
    end

    @html = "<table>"
    @rows.each do |row|
      unless row.blank?
        @html += "\n\t<tr>\n\t\t#{row.map{|v| '<td>' + v + '</td>'}}\n\t</tr>"
      end
    end
    @html += "\n</table>"
    @html
  end

  def cabinet_link(cabinet, use_ajax_style=false)
    if use_ajax_style
      link = link_to_remote(cabinet.name, :url => {:action => 'show_cabinet', :id => cabinet},
                            :update => 'cabinet_view')
    else
      link = "<a href=\"#cabinet_#{cabinet.id.to_s}\">#{cabinet.name}</a>"
    end
    link
  end

end
