module DateHelper
  def short_date(date)
    date.strftime('%d/%m/%Y')
  end
end
