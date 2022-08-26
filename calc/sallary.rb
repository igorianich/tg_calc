require "active_support/all"

class Sallary
  def calc(hs: 0, vacations: 0, days_off: 0, holydays: 0, der: 36.57)
    today = Date.current
    wd_ds_count = (today.beginning_of_month..today).map { |day| day.saturday? || day.sunday? ? nil : day }.compact.count - holydays
    m_w_ds_count = (today.beginning_of_month..today.end_of_month).map { |day| day.saturday? || day.sunday? ? nil : day }.compact.count - holydays
    c_hs_norm = wd_ds_count * 8.0
    c_hs_norm_doff = (wd_ds_count - days_off) * 8.0
    m_hs_norm = m_w_ds_count * 8.0
    real_hs = hs + vacations * 8.0
    diff_string = (real_hs - c_hs_norm).round(1); diff_string = diff_string.positive? ? "+#{diff_string}" : diff_string
    diff_doff_string = (real_hs - c_hs_norm_doff).round(1); diff_doff_string = diff_doff_string.positive? ? "+#{diff_doff_string}" : diff_doff_string

    str_hs_norm =     "Місячна норма:\n#{m_hs_norm} год."
    hs_left =         "Залишилось :\n#{m_hs_norm - real_hs} год."
    diff =            "Різниця з нормою:\n#{diff_string} год."
    diff_doff =       "Різниця з нормою без дейофів:\n#{diff_doff_string} год." unless c_hs_norm == c_hs_norm_doff
    hour_rate = (1000.0 / m_hs_norm).round(2)
    logged_sallary = (hour_rate * real_hs).round(2)
    fin_sallary = (logged_sallary - (logged_sallary * 0.05) - 1430 / der).round(2)
    hour_rate =       "Твій погодинний рейт:\n#{(1000.0 / m_hs_norm).round(2)}$."
    logged_sallary =  "Поточна зарплата:\n#{logged_sallary}$ / #{(logged_sallary * der).round(2)}₴."
    tax_sallary =     "Поточна зарплата включаючи податки:\n#{fin_sallary}$ / #{(fin_sallary * der).round(2)}₴."
    fin_sallary =     "Включаючи податки і компенсації:\n#{(fin_sallary + 750/ der).round(2)}$ / #{(fin_sallary * der + 750).round(2)}₴."
    [str_hs_norm, hs_left, diff, diff_doff, logged_sallary, tax_sallary, fin_sallary, hour_rate].compact.join("\n")
  end
end