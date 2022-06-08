module Admin::CandidatesHelper
  CANDIDATES_EMAILS_URL = 'https://drive.google.com/open?id=1GhZRQodsZZsXyVa-lp4KjH67VqZlbF5tcYaCBwk8uyw'

  def style(report_part, type)
    if report_part == 'body'
      if type == 'grouping'
        'string'
      elsif type == 'status'
        'number'
      else
        'bold_number'
      end
    else
      type == 'grouping' ? 'string' : 'number'
    end
  end

  def data_type(i)
    @report['header'][@report['header'].keys[i]]
  end

end
