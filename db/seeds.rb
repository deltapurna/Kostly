# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Array of good words in Bahasa Indonesia
good_words = %w(
  murah
  nyaman
  menyenangkan
  aman
  sejahtera
  sentosa
  sehat
  menggembirakan
  strategis
  anti-maling
  terjangkau
  dekat-kampus
  berhadiah
  parkir-luas
)

# create 20 fake data everytime we run rake db:seed
20.times do
  # this will take 2/3 words in random from array good words and make sentence
  # with word 'dan' as connector
  # example:
  # 1. murah, nyaman dan berhadiah
  # 2. sheat dan menggembirakan
  catch_phrases = good_words.sample([2,3].sample).
    to_sentence(two_words_connector: ' dan ', last_word_connector: ' dan ')

  Place.create!(
    name: "Kos #{Faker::Address.city}",
    description: "Kosan #{catch_phrases}. #{Faker::Lorem.paragraph(3)}"
  )
end
