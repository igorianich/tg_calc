require 'telegram/bot'
require './calc/sallary'

token = '733527740:AAG3GleueqIA07EWVDe9_aTvyIHppc69U6E'

result_hash = { hs: 0, vacations: 0, days_off: 0, holydays: 0, der: 36.57 }


Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|

    # answers =
    #   Telegram::Bot::Types::ReplyKeyboardMarkup
    #     .new(keyboard: ['Обрахунок зарплати'], one_time_keyboard: true)
    case message
    when Telegram::Bot::Types::Message
      case message.text
      when '/start'
        answers =
          Telegram::Bot::Types::ReplyKeyboardMarkup
            .new(keyboard: ['Обрахунок зарплати'], one_time_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}, виберіть пункт меню", reply_markup: answers)
        # bot.api.send_message(
        #   chat_id: message.chat.id,
        #   text: "Hello, #{message.from.first_name}"
        # )
      when 'Показати всі параметри'
        bot.api.send_message(chat_id: message.chat.id, text: result_hash.to_s)
      when 'Обрахунок зарплати'
        kb = [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Внести години (#{result_hash[:hs]})", callback_data: 'enter_hours'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Внести відпустки (#{result_hash[:vacations]})", callback_data: 'enter_vacations'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Внести дейофи (#{result_hash[:days_off]})", callback_data: 'enter_days_off'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Внести свята (#{result_hash[:holydays]})", callback_data: 'enter_holydays'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Внести курс (#{result_hash[:der]})", callback_data: 'enter_der'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: "Виконати розрахунок", callback_data: 'calculate')
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        bot.api.send_message(chat_id: message.chat.id, text: 'Зробіть вибір', reply_markup: markup)
      when '/stop'
        bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      else
        unless message.reply_to_message.nil?
          calculate = Telegram::Bot::Types::InlineKeyboardButton.new(text: "Виконати розрахунок", callback_data: 'calculate')
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [calculate])
          case message.reply_to_message.text
          when 'Внести години'
            result_hash[:hs] = message.text.to_i
            bot.api.send_message(chat_id: message.chat.id, text: "Ви ввели #{result_hash[:hs]} годин", reply_markup: markup)
          when 'Внести відпустки'
            result_hash[:vacations] = message.text.to_i
            bot.api.send_message(chat_id: message.chat.id, text: "Ви ввели #{result_hash[:vacations]} днів", reply_markup: markup)
          when 'Внести дейофи'
            result_hash[:days_off] = message.text.to_i
            bot.api.send_message(chat_id: message.chat.id, text: "Ви ввели #{result_hash[:days_off]} днів", reply_markup: markup)
          when 'Внести свята'
            result_hash[:holydays] = message.text.to_i
            bot.api.send_message(chat_id: message.chat.id, text: "Ви ввели #{result_hash[:holydays]} днів", reply_markup: markup)
          when 'Внести курс'
            result_hash[:der] = message.text.to_f
            bot.api.send_message(chat_id: message.chat.id, text: "Ви ввели курс #{result_hash[:der]}", reply_markup: markup)
          end
        end
      end
    when Telegram::Bot::Types::CallbackQuery
      case message.data
      when 'enter_hours'
        answer = Telegram::Bot::Types::ForceReply.new(force_reply: true, input_field_placeholder: '25')
        bot.api.send_message(
          chat_id: message.from.id, text: 'Внести години', is_automatic_forward: true,
          reply_markup: answer, selective: true
        )
      when 'enter_vacations'
        answer = Telegram::Bot::Types::ForceReply.new(force_reply: true, input_field_placeholder: '0')
        bot.api.send_message(chat_id: message.from.id, text: 'Внести відпустки', is_automatic_forward: true, reply_markup: answer, selective: true)
      when 'enter_days_off'
        answer = Telegram::Bot::Types::ForceReply.new(force_reply: true, input_field_placeholder: '0')
        bot.api.send_message(chat_id: message.from.id, text: 'Внести дейофи', is_automatic_forward: true, reply_markup: answer, selective: true)
      when 'enter_holydays'
        answer = Telegram::Bot::Types::ForceReply.new(force_reply: true, input_field_placeholder: '0')
        bot.api.send_message(chat_id: message.from.id, text: 'Внести свята', is_automatic_forward: true, reply_markup: answer, selective: true)
      when 'enter_der'
        answer = Telegram::Bot::Types::ForceReply.new(force_reply: true, input_field_placeholder: '36.7')
        bot.api.send_message(chat_id: message.from.id, text: 'Внести курс', is_automatic_forward: true, reply_markup: answer, selective: true)
      when 'calculate'
        result = Sallary.new.calc(**result_hash)

        bot.api.send_message(chat_id: message.from.id, text: result)
      end
    end
  end
end