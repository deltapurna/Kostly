## Belajar Rails Session 6
# MODEL VALIDATIONS AND ASSOCIATIONS

Link Heroku:
<https://belajarrails2.herokuapp.com>

Link Github:
<https://github.com/deltapurna/Kostly/commits/master>

## Model Validations
- form kita untuk membuat object `place` sudah selesai, tapi sekarang user kita bisa mensubmit apapun bahkan empty string
- kita bisa mencegah ini dengan menambahkan validasi
- di rails validasi didefinisikan di model
- beberapa validasi yang umum digunakan antara lain `presence`, `uniqueness`, `length`, `inclusion` dan `format`
- kita juga bisa mendefinisikan validasi kita sendiri jika dibutuhkan
- validasi untuk model `Place`:
  + validasi `presence` untuk atribut `name` dan `description`
  + validasi `length` (maksimum 400 karakter) untuk atribut `description`

            # app/models/place.rb
            class Place < ActiveRecord::Base
              validates :name, :description, { presence: true }
              validates :description, length: { maximum: 400 }
            end

- kita bisa memastikan validasi kita berjalan di rails console (bisa menggunakan method `valid?` dan `errors`)

        # bin/rails console
        p = Place.new
        p.valid?
          #=> false
        p.errors.full_messages
          #=> ["Name can't be blank", "Description can't be blank"]
        p.description = 'a' * 401 # karena limitnya adalah 400, kita set sebagai 401
        p.valid?
          #=> false
        p.errors.full_messages
          #=> ["Name can't be blank", "Description is too long (maximum is 400 characters)"]

- kemudian kita bisa menghandle apa yang akan kita lakukan jika sebuah model gagal di save di controller kita (save akan return `false` jika validasi gagal)
- simplenya kita akan menampilkan kembali new place form dengan error messagenya

        # app/controllers/places_controllers.rb
        class PlacesController < ApplicationController
          ...
          def create
            @place = current_user.places.build(place_params)
            if @place.save
              redirect_to places_url, notice: 'Place created!'
            else
              render :new
            end
          end
          ...
        end

- kemudian kita update view kita dengan memanfaatkan `@place.errors` attribute

        <!-- app/views/places/_form.html.erb -->
        <% if @place.errors.any? %>
          <div class='alert alert-danger'>
            <strong><%= pluralize @place.errors.count, 'error' %> prevented place to be submitted </strong>
            <ul>
              <% @place.errors.full_messages.each do |msg| %>
                <li><%= msg %></li>
              <% end %>
            </ul>
          </div>
        <% end %>


## Associating Place and User

### Generating 2nd Model: User
- menggunakan generator model
- `bin/rails generate model user name:string email:string`
  + akan menggenerate `user.rb` di `app/models` folder
  + file migration untuk membuat database `users` (lengkap dengan kolom `name` dan `email`)
  + dan test files
- jalankan `bin/rake db:migrate`

### Setup foreign key column in table places
- `bin/rails generate migration AddUserIdToPlaces user_id:integer`
- ini adalah special syntax untuk mengenerate migration untuk menambah column di table

          # db/migrate/xxxxx_add_user_id_to_places.rb
          class AddUserIdToPlaces < ActiveRecord::Migration
            def change
              add_column :places, :user_id, :integer
            end
          end

- kuncinya ada di format namanya: `AddXXXTo<table_name>` dan column name dan tipe di belakangnya
- syntax yang mirip juga ada untuk remove column dengan format `RemoveXXXFrom<table_name>`
- jalankan `bin/rake db:migrate`

### Setup association in model
- untuk mendeklarasikan bahwa user punya banyak places cukup dengan 1 line

          # app/models/user.rb
          class User < ActiveRecord::Base
            ...
            has_many :places
          end

- dan sebaliknya untuk mendeklarasikan bahwa sebuah place dimiliki oleh seorang user juga cukup dengan 1 line

          # app/models/place.rb
          class Place < ActiveRecord::Base
            ...
            belongs_to :user
          end

### Additional Active Record Methods after Association
- mencari places yang dimiliki user tertentu:
  + `user.places` => mengembalikan kumpulan places (array) dengan `user_id` dari `user`
  + `user.places.where(name: 'Kosan Cendrawasih'` => bekerja juga dengan `where` query seperti biasa
  + `user.places.find_by(name: 'Kosan Cendrawasih'` => atau `find_by` query
- membuat places yang dimiliki user tertentu:
  + `user.places.create(params)` => create place dengan `user_id` dari `user`
  + `user.places.build(params)` => inisiasi (seperti `Place.new`) dengan `user_id` dari `user`
- mencari user yang memiliki place tertentu:
  + `place.user` => mengembalikan object user yang memiliki place

### Updating Seed Data

        # db/seeds.rb
        ...
        user = User.create!(name: 'Delta Purna W.', email: 'd@qiscus.com')
        user2 = User.create!(name: 'Ashari Juang', email: 'j@qiscus.com')

        # create 20 fake data with user and user2 everytime we run rake db:seed
        10.times do
          user.places.create!(
            name: "Kos #{Faker::Address.city}",
            description: "#{Faker::Lorem.paragraph(3)}"
          )
          user2.places.create!(
            name: "Kos #{Faker::Address.city}",
            description: "#{Faker::Lorem.paragraph(3)}"
          )
        end

- reset migration dengan `bin/rake db:migrate:reset`
- dan kemudian rerun seed data yang baur `bin/rake db:seed`

## Showing User List of Places in Profile
- setup validasi untuk user
  + validasi `presence` untuk atribut `name` dan `email`
  + validasi `uniqueness` dan `format` untuk atribut `email`

              # app/models/user.rb
              class User < ActiveRecord::Base
                VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
                validates :name, :email, presence: true, length: { maximum: 255 }
                validates :email, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
                ...
              end

- buat controller baru untuk users dengan generator controller
- `bin/rails generate controller users show`
  + => will generate `users_controller.rb` in `app/controllers` folder
  + dan beberapa file test dan assets
  + dan juga action dan view `show` (untuk menampilkan 1 user)
- update routes config file dengan RESTful routing untuk `users`

          # config/routes.rb
          Rails.application.routes.draw do
            ...
            resources :users
            ...
          end

- query user dengan `params[:id]` di controller `users`

          class UsersController < ApplicationController
            def show
              @user = User.find(params[:id])
            end
          end

- update view dengan profile user dan list places yang dimiliki `@user`

          ...Coming Soon

**VOILA! Sekarang dengan mengakses <http://localhost:3000/users/1> kita akan melihat profile `user` delta dengan tempat-tempat yang dimilikinya! (gunakan `/users/2` untuk melihat profile user juang)**

**TUGAS! Buat sign up form dan edit profile form (menggunakan action `new`, `create`, `edit` dan `update` users)**

**Plus point jika menggunakan routing `/sign_up` untuk sign up form (bukan `/users/new`)**

## Notes when deploying to heroku
- kita perlu mereset database di production dengan `heroku pg:reset DATABASE`
- kemudian run migration di heroku `heroku run rake db:migrate`
- dan merun seed data juga di heroku `heroku run rake db:seed`

## Referensi
- Rails Guide - Active Record Validations (<http://guides.rubyonrails.org/active_record_validations.html>)
- Rails Guide - Active Record Associations (<http://guides.rubyonrails.org/association_basics.html>)
