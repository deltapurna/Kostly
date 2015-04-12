## Belajar Rails Session 5
# REST CONTROLLER FOR PLACE

Link Heroku:
<https://belajarrails2.herokuapp.com>

Link Github:
<https://github.com/deltapurna/Kostly/commits/master>

## Tentang REST
- > Network Architectural Style (Roy Fielding)
- Resources (noun)
  + bisa di akses/manipulasi dengan URI
- standar method HTML (verb)
  + GET
  + POST
  + PUT/PATCH
  + DELETE
- contoh controller yang kurang RESTful

        # app/controllers/users_controller.rb
        class UsersController < ApplicationController
          def login_to_website
          ...
          end

          def subscribe_to_mailing_list
          ...
          end

          def process_credit_card_transaction
          ...
          end

        end

  + filenya besar sekali
  + seringkali menghandle banyak model dalam 1 controller
- contoh RESTful controller

        # app/controllers/users_controller.rb
        class UsersController < ApplicationController

          # GET /users/3
          def show
          ...
          end

          # POST /users
          def create
          ...
          end

          # PATCH /users/3
          def update
          ...
          end

          # DELETE /users/3
          def destroy
          ...
          end

        end

  + memanfaatkan berbagai macam http request verb untuk menyederhanakan URI
  + 1 controller menghandle 1 resource

## Rails Support untuk REST
### RESTful routing
- kita bisa dengan mudah mendefinisikan resource di routing dengan keyword `resource`
- untuk mendefinisikan places sebagai resource kita, cukup dengan 1 line code:

        Rails.application.routes.draw do
          ...
          resources :places
          ...
        end
- ini akan menghasilkan 8 RESTful routes untuk manipulasi resource dengan nama `places`

        # bin/rake routes
        Prefix Verb   URI Pattern                Controller#Action
            ...
            places GET    /places(.:format)          places#index
                   POST   /places(.:format)          places#create
         new_place GET    /places/new(.:format)      places#new
        edit_place GET    /places/:id/edit(.:format) places#edit
             place GET    /places/:id(.:format)      places#show
                   PATCH  /places/:id(.:format)      places#update
                   PUT    /places/:id(.:format)      places#update
                   DELETE /places/:id(.:format)      places#destroy
            ...

- patut diperhatikan bahwa rails memanfaatkan http verb yang sesuai untuk setiap routing

### RESTful controller
routing seperti disebutkan di atas mengasumsikan 7 action akan didefinisikan di controller bernama `places`:

- `index` action: biasanya di gunakan untuk listing resource yang ada di database
- `show` action: biasanya di gunakan untuk menampilkan 1 resource dengan id tertentu
- `new` & `create` actions: sepasang actions untuk membuat resource, `new` untuk menampilkan form, dan `create` untuk logika pembuatan resourcenya (target dari formnya)
- `edit` & `update` actions: sepasang actions untuk mengupdate resource, `edit` untuk menampilkan form, dan `update` untuk logika mengupdate resourcenya (target dari edit form)
- `destroy` action: biasanya digunakan untuk meremove resource dari database

## Places Controller
- menggunakan generator controller
- `bin/rails generate controller places`
    + => will generate `places_controller.rb` in `app/controllers` folder
    + dan beberapa file test dan assets
### Listing Places
- menampilkan semua places di database
- gunakan query `all` di controller

        # app/controllers/places_controller.rb
        class PlacesController < ApplicationController
          # GET /places
          def index
            @places = Place.all
          end
        end

- kemudian tampilkan di view

        <!-- app/views/places/index.html.erb -->
        <h1>Listing Places</h1>
        <%= link_to 'Add Place', new_place_path, class: 'btn btn-primary' %>
        <table class='table table-striped'>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Description</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <% @places.each do |place| %>
              <tr>
                <td><%= place.id %></td>
                <td><%= place.name %></td>
                <td><%= place.description %></td>
                <td width='30%'>
                  <div class='btn-group'>
                    <%= link_to 'View', place_path(place), class: 'btn btn-default' %>
                    <%= link_to 'Edit', edit_place_path(place), class: 'btn btn-default' %>
                    <%= link_to 'Delete', place_path(place), class: 'btn btn-default', method: :delete, data: { confirm: 'Are you sure?' } %>
                  </div>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>

- jangan lupa update navigasi di `_header.html.erb` agar kita bisa mengakses halaman listing

        <!-- app/views/layouts/_header.html.erb -->
        ...
        <ul class="nav navbar-nav">
          <li class="active"><a href="/places">Browse <span class="sr-only">(current)</span></a></li>
          <li><a href="#">My Places</a></li>
        </ul>
        ...

### Create a Place
- Membuat sebuah tempat menggunakan 2 action, `new` untuk menampilkan form, dan `create` untuk menangkap parameter dari form dan menyimpan di database

#### Menampilkan Create Place Form
- inisiasi object dari model `Place` di controller

        # app/controllers/places_controller.rb
        class PlacesController < ApplicationController
          ...
          def new
            @place = Place.new
          end
          ...
        end

- gunakan form helper untuk membuat form di view
  + form helper memungkinkan kita melink antara rails model dengan form

            <!-- app/views/places/new.html.erb -->
            <h2>Submit your place!</h2>
            <%= form_for @place do |f| %>
              <div class='form-group'>
                <%= f.label :name %>
                <%= f.text_field :name, class: 'form-control' %>
              </div>
              <div class='form-group'>
                <%= f.label :description %>
                <%= f.text_area :description, class: 'form-control' %>
              </div>

              <%= f.submit class: 'btn btn-primary btn-block' %>
            <% end %>

    + `form_for` method akan dengan sangat pintar menyesuaikan dengan state dari object `@place`:
      - jika `@place` adalah object baru, form ini adalah form untuk membuat object (melakukan `POST` request ke `/places`)
      - jika `@place` ini adalah existing object di databse, form ini adalah form untuk mengupdate object
    + ini memungkinkan refactoring form untuk membuat dan mengupdate menjadi sebuah partial

#### Menangkap parameter dari form dan menyimpan di database
- tempatkan logika ini di `create` action di controller
- action ini biasanya tidak memiliki view sendiri karenanya kita bisa menggunakan `redirect_to` untuk meredirect request ke tempat lain

            class PlacesController < ApplicationController
              ...
              def create
                @place = Place.new(place_params)
                @place.save
                redirect_to places_url, notice: 'Place created!'
              end
              ...
              private
              def place_params
                params.require(:place).permit(:name, :description)
              end
            end

- patut diperhatikan kita perlu secara spesifik me-whitelist parameter yang di submit oleh user karena security concern (bisa di lihat di private method `place_params`)
- teknik ini di sebut dengan __strong parameters__ di rails
- dengan ini kita memastikan bahwa kita hanya menyimpan `name` dan `description` dari form yang di submit user
- jangan lupa untuk menampilkan notice di layout file kita, agar user bisa tahu kalau form yang dia submit telah berhasil di simpan
- message seperti ini disebut dengan __flash__ message di rails, dan bisa di setup di method `redirect_to` yang kita panggil di action `create` di atas

            <!-- app/views/layouts/application.html.erb -->
            ...
            <div class='container'>
              <% if notice %>
                <div class='alert alert-success'><%= notice %></div>
              <% end %>
              ...
            </div>
            ...


**VOILA! Sekarang kita bisa mengakses halaman browse (menampilkan list places) dan juga mensubmit place baru! AWESOME!**

**TUGAS! Buat action controller untuk `show`, `edit`, `update` dan `destroy` beserta viewnya**

## Referensi
- Rails Guide - Resource Routing (<http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default>)
- Rails Guide - Form Helpers - Dealing with Model Objects (<http://guides.rubyonrails.org/form_helpers.html#dealing-with-model-objects>)
- Rails Guide - Strong Parameters (<http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters>)
- Rails Guide - Flash (<http://guides.rubyonrails.org/action_controller_overview.html#the-flash>)
