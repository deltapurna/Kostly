# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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


20.times do
  catch_phrases = good_words.sample([2,3].sample).to_sentence(two_words_connector: ' dan ', last_word_connector: ' dan ')

  Place.create!(
    name: "Kos #{Faker::Address.city}",
    description: "Kosan #{catch_phrases}. #{Faker::Lorem.paragraph(3)}"
  )
end
