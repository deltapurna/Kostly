## Belajar Rails Session 2
# OUR FIRST MODEL: PLACE

Link Heroku:
<https://belajarrails2.herokuapp.com>

Link Github:
<https://github.com/deltapurna/Kostly/commits/master>

## Generating Model
- menggunakan generator model
- generator ini membutuhkan nama model dan (optional) field-field yang model ini butuhkan di database
- `bin/rails generate model place name:string description:text`
  + akan menggenerate `place.rb` di `app/models` folder
  + file migration untuk membuat database `places` (lengkap dengan kolom `name` dan `description`)
  + dan test files
- jalankan `bin/rake db:migrate`

### Tentang Migration
- adalah cara yang mudah dan elegan untuk merubah schema database kita
- Setiap migration akan membuat versi baru dari schema database kita
- migration bisa di terapkan di database dengan command `bin/rake db:migrate`
- kita bisa mengembalikan ke versi sebelumnya dengan `bin/rake db:rollback`
- rails support berbagai macam syntax untuk manipulasi database, diantaranya:
  + Membuat table `create_table`
  + Merubah column `change_column`
  + Merubah nama column `rename_column`
  + dan lain sebagainya

## Introducing Rails Console
- merupakan tools yang sangat berguna untuk development
- seperti `irb`, tapi kita bisa mengakses environment rails kita
- kita bisa mengakses routes, controller, model dan data di database kita!
- kita bisa masuk console dengan menjalankan `bin/rails console`
- jika kita takut merubah data ketika menjalankan `console`, kita bisa menggunakan `sandbox` mode `bin/rails console --sandbox`
- di sesi ini kita akan menggunakan `console` untuk berkenalan dengan Active Record

## Introducing Active Record
- [Active Record](http://www.martinfowler.com/eaaCatalog/activeRecord.html) dijelaskan oleh Martin Fowler di bukunya.
- _"An object that wraps a row in a database table or view, encapsulates the database access, and adds domain logic on that data."_
- beberapa orang juga menyebut pattern ini dengan _ORM_ (Object Relational Mapping)
  + class `Place` <=> Table 'places'
  + object dari class `Place` <=> Row di table `places`
  + attribute dari objectnya <=> Column di table `places`
- menggunakannya cukup membuat class `Place`, dan inherit dari `ActiveRecord::Base`

        # app/models/place.rb
        class Place < ActiveRecord::Base
        end

- dan pastikan di database ada table dengan nama `places`

        # db/schema.rb
        ActiveRecord::Schema.define(version: 20150322084554) do
          create_table "places", force: :cascade do |t|
            t.string   "name"
            t.text     "description"
            t.datetime "created_at",  null: false
            t.datetime "updated_at",  null: false
          end
        end

- untuk memastikan semua berjalan lancar, jalankan `console` dan ketik `Place.all`

        >> Place.all
          Place Load (0.4ms)  SELECT "places".* FROM "places"
        => #<ActiveRecord::Relation []>

- seperti bisa dilihat, `Place.all` akan menjalankan SQL query `SELECT * from "places"` dan mengembalikan array kosong (karena kita belum punya data)

## CRUD Operation dengan Active Record
- Dengan Active Record, kita dengan mudah bisa menjalankan operasi database tanpa membuat sql query dari scratch

### CREATE
- dengan `new` dan `save`
  - `p = Place.new` #=> Menginisiasi object baru dan di simpan di sebuah variable `p`
  - `p.name = 'Kosan Cendrawasih'` #=> menset value untuk name dari place
  - `p.description = 'Kosan bersih, murah dan nyaman'` #=> menset value untuk description dari place
  - `p.save` #=> menyimpan object `p` ke database
- `new` juga menerima `hash` sebagai parameter
  - `place_params = { name: 'Kosan Cendrawasih', description: 'Kosan bersih, murah dan nyaman' }` #=> membuat `hash` baru
  - `p = Place.new(place_params)` #=> inisiasi object baru dengan menggunakan `place_params` hash
  - `p.save` #=> menyimpan object `p` ke database
- `new` dan `save` bisa di ringkas menggunakan `create`
  - `place_params = { name: 'Kosan Cendrawasih', description: 'Kosan bersih, murah dan nyaman' }` #=> membuat `hash` baru
  - `p = Place.create(place_params)` #=> inisiasi object baru dengan menggunakan `place_params` hash dan disimpan di database

### READ
- `all` akan mengembalikan semua data dari database
  - `places = Place.all` #=> Mengambil semua data dari table places dan disimpan di variable `places`
- `where(:hash)` akan mengembalikan data-data dengan kriteria tertentu
  - `places = Place.where(name: 'Kosan Cendrawasih')` #=> mengembalikan semua data dari database dengan nama = 'Kosan Cendrawasih'
  - `places = Place.where('description LIKE ?', '%murah%')`
- `first` or `last` mengembalikan data pertama atau terakhir
  - `place = Place.first`
  - `place = Place.last`
- `find(:id)` mengembalikan data dengan id tertentu
  - `place = Place.find(3)` #=> Mengambil data dengan id = 3
- `find_by(:hash)` mengembalikan 1 data dengan kriteria tertentu
  - `place = Place.find_by(name: 'Kosan Cendrawasih')`

### UPDATE
- `update(:hash)` akan mengupdate object sesuai dengan kriteria yang ditentukan di `hash`
  - `place = Place.find(1)` #=> gunakan find / method lain untuk menemukan data yang akan di update
  - `place.update(name: 'Kosan Merak')` #=> update kemudian bisa dipanggil di object `place` dengan parameter hash yang akan di ganti

### DESTROY
- `destroy` akan menghilangkan data dari database
  - `place = Place.find(1)` #=> gunakan find / method lain untuk menemukan data yang akan di update
  - `place.destroy` #=> menghilangkan object `place` dari database


- **TUGAS: Create minimal 10 places di database masing-masing!**
- **TUGAS 2: Create minimal 10 places lagi di database masing-masing! kali ini menggunakan `seed` file! (Silahkan di google :))**

## Displaying Places at Homepage
- query semua `place` di database di controller `static_pages`

        # app/controllers/static_pages_controller.rb
        class StaticPagesController < ApplicationController
          def home
            @places = Place.all
          end
          ...
        end

- gunakan instance variable `@places` di view template

        <!-- app/views/static_pages/home.html.erb -->
        ...
          <!-- looping ke semua place di dalam array @places -->
          <% @places.each do |place| %>
            <div class="col-md-3 columns place-item">
              ...
              <!-- gunakan place.name -->
              <h2><%= place.name %></h2>
              <!-- gunakan place.description dengan truncate helper -->
              <p><%= truncate place.description, length: 50 %></p>
              ...
            </div>
          <% end %>
        ...

- **VOILA! Sekarang homepage kita telah menampilkan data dari database dan bisa di akses di <http://localhost:3000>**
- **TUGAS: Buat query untuk menampilkan hanya 8 most updated place di homepage!**

## Notes when deploying to heroku
- jangan lupa untuk merun migration di heroku `heroku run rake db:migrate`
- dan merun seed data juga di heroku `heroku run rake db:seed`
- kita juga bisa mengakses console di server heroku `heroku run console`
- jika ada error bisa kita cek log dengan `heroku logs`

## Referensi
- Rails Guide - Active Record Migrations (<http://guides.rubyonrails.org/active_record_migrations.html>)
- Rails Guide - Rails Console (<http://guides.rubyonrails.org/command_line.html#rails-console>)
- Rails Guide - Active Record Basics (<http://guides.rubyonrails.org/active_record_basics.html>)
- Rails Guide - Active Record Query Interface (<http://guides.rubyonrails.org/active_record_querying.html>)
- Rails Guide - Seed Data (<http://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data>)
- Heroku Command (<https://devcenter.heroku.com/articles/getting-started-with-rails4#migrate-your-database>)
