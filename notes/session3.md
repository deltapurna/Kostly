## Belajar Rails Session 3
# LAYOUTING WITH BOOTSTRAP

Link Heroku:
<https://belajarrails2.herokuapp.com>

Link Github:
<https://github.com/deltapurna/Kostly/commits/master>

## Special Routing: Root route
- Kita bisa mendefinisikan controller dan action yang akan tertrigger jika user mengakses route `/`

        # config/routes.rb
        root 'static_pages#home'

- Dengan konfigurasi ini, ketika kita mengakses <http://localhost:3000> akan punya tampilan yang sama dengan mengakses <http://localhost:3000/home>

## Installing Bootstrap
- Bootstrap (<http://getbootstrap.com/>) merupakan salah satu front end framework yang paling populer
- Alternatifnya antara lain Foundation framework (<http://foundation.zurb.com>)
- Bootstrap sangat mudah untuk diintegrasikan ke rails, cukup menggunakan gem bootstrap-sass
- detail instruksi bisa mengikuti dokumentasinya di githubnya (<https://github.com/twbs/bootstrap-sass#a-ruby-on-rails>)

        # Gemfile
        gem 'bootstrap-sass'

- `bundle install`
- buat sebuah file sass, misalnya dengan nama `style.scss` di folder assets

        // app/assets/stylesheets/style.scss
        @import "bootstrap-sprockets";
        @import "bootstrap";

- jangan lupa include bootstrap javascript di application.js (setelah jquery)

        // app/assets/javascripts/application.js
        //= require jquery
        //= require bootstrap-sprockets

- restart rails server
- Sekarang mengakses <http://localhost:3000> akan menampilkan typical warna dan typography dari bootstrap :)

## Layout styling dengan Partial

### Menambahkan Navigasi Bootstrap
- Buat sebuah file baru di folder layout dengan nama `_header.html.erb`
- File ini dengan nama file diawali dengan underscore (`_`) adalah file partial
- File ini bisa di include ke file template apapun
- Nanti ketika berinteraksi dengan AJAX juga file ini bisa digunakan sebagai response dari controller untuk request AJAX
- Cara menginclude file partial di template dengan menggunakan fungsi `render` di view kita

        <!-- app/views/layouts/application.html.erb -->
        <body>
          <%= render 'layouts/header' %> <!-- ini akan mencari file _header.html.erb di folder layouts -->
          <%= yield %>
        </body>

- Kita bisa mengisi file `_header.html.erb` dengan template navigasi bootstrap

        <!-- app/views/layouts/_header.html.erb -->
        <nav class="navbar navbar-default navbar-static-top">
          <div class="container">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
               <a href="#" class="navbar-brand" id="logo">Kostly</a>
            </div>
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
              <ul class="nav navbar-nav">
                <li class="active"><a href="#">Browse <span class="sr-only">(current)</span></a></li>
                <li><a href="#">My Places</a></li>
              </ul>
              <ul class="nav navbar-nav navbar-right">
                <li><a href="#">Sign In</a></li>
                <li><a href="#">Sign Up</a></li>
                <li class="dropdown">
                  <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Hi Delta <span class="caret"></span></a>
                  <ul class="dropdown-menu" role="menu">
                    <li><a href="#">Edit Profile</a></li>
                    <li class="divider"></li>
                    <li><a href="#">Sign Out</a></li>
                  </ul>
                </li>
              </ul>
            </div><!-- /.navbar-collapse -->
          </div><!-- /.container-fluid -->
        </nav>

- Sekarang karena kita sudah menginclude file ini di file layout kita `application.html.erb`, mengakses <http://localhost:3000> akan menampilkan navigasi boostrap

### Menambahkan Footer
- metode yang sama bisa kita lakukan untuk footer juga agar layout kita lebih mudah di maintain
- buat file `_footer.html.erb` di folder layouts
- include file tersebut di layout `application.html.erb` kita

        <!-- app/views/layouts/application.html.erb -->
        <body>
          <%= render 'layouts/header' %>
          <div class='container'>
            <%= yield %>
            <%= render 'layouts/footer' %> <!-- ini akan mencari file partial _footer.html.erb di folder layouts -->
          </div>
        </body>

- kita bisa mengisi file `_footer.html.erb` dengan template footer sederhana

        <!-- app/views/layouts/_footer.html.erb -->
        <footer>
        <small>
          Belajar Rails 2
        </small>
        <nav>
          <ul>
            <li><a href="#">About</a></li>
          </ul>
        </nav>
        </footer>

### Simple Styling for Logo and Footer
- Kita dengan mudah bisa mengoverride style dari bootstrap jika diperlukan
- Dan kita bisa menggunakan fitur-fitur Sass karena ini adalah file SCSS :)


        /* app/assets/stylesheets/style.scss */
        @import "bootstrap-sprockets";
        @import "bootstrap";
        $gray-medium-light: #eaeaea;
        /* header */
        #logo {
          float: left;
          margin-right: 10px;
          font-size: 1.7em;
          text-transform: uppercase;
          letter-spacing: -1px;
          font-weight: bold;
          &:hover {
            text-decoration: none;
          }
        }
        /* footer */
        footer {
          margin-top: 45px;
          padding-top: 5px;
          border-top: 1px solid $gray-medium-light;
          small {
            float: left;
          }
          ul {
            float: right;
            list-style: none;
            li {
              float: left;
              margin-left: 15px;
            }
          }
        }

- Sekarang mengakses <http://localhost:3000> akan menampilkan layout yang sudah kita selesaikan

## Linking the Pages with View Helpers

### Tentang helper
- Helper adalah tools lain yang bisa kita gunakan untuk mempermudah kita dalam memaintain code di view aplikasi rails kita
- Helper adalah ruby method yang bisa kita panggil dari view yang mengembalikan snippets template untuk view tersebut
- method `render` yang kita gunakan untuk menampilkan partial merupakan salah satu contohnya
- kita juga pernah melihat beberapa method helper lainnya


        <!-- app/views/layouts/application.html.erb -->
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title><%= yield(:title) %> | Kostly</title>
          <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
          <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
          <%= csrf_meta_tags %>
        </head>

- `stylesheet_link_tag` merupakan helper untuk menambahkan link tag ke css tertentu
- `javascript_include_tag` merupakan helper untuk menambahkan javascript file
- rails menyediakan banyak helper yang tinggal kita gunakan untuk di view-view kita
- kita juga bisa mendefinisikan sendiri helper kita sesuai kebutuhan aplikasi kita

### Beberapa contoh helper yang diberikan rails
- TextHelper - Helper yang berkaitan dengan manipulasi text
  - `pluralize`: digunakan untuk mempluralkan sebuah kata

            pluralize(1, 'man') # => 1 man

            pluralize(2, 'men') # => 2 men

  - `truncate`: digunakan untuk memotong sebuah text yang panjang sesuai kebutuhan

            truncate("Once upon a time in a world far far away")
            # => "Once upon a time in a world..."

            truncate("Once upon a time in a world far far away", length: 17)
            # => "Once upon a ti..."

            truncate("And they found that many people were sleeping better.", length: 25, omission: '... (continued)')
            # => "And they f... (continued)"

- NumberHelper - Helper yang berkaitan dengan manipulasi angka
  - `number_to_currency`: digunakan untuk merubah angka menjadi tampilan mata uang

            number_to_currency(1234567890.50)
            # => $1,234,567,890.50

            number_to_currency(1234567890.50, unit: 'Rp. ')
            # => Rp. 1,234,567,890.50

  - `number_to_human`: digunakan untuk merubah angka menjadi string yang mudah dibaca

            number_to_human(12345)
            # => "12.3 Thousand"

            number_to_human(1234567890)
            # => "1.23 Billion"

- UrlHelper - helper yang berkaitan dengan membuat link atau mendapatkan URL

  - `link_to`: membuat link ke route lain sesuai kebutuhan

            link_to "Profile", profile_path(@profile)
            # => <a href="/profiles/1">Profile</a>

            link_to "Destroy", "http://www.example.com", method: :delete
            # => <a href='http://www.example.com' rel="nofollow" data-method="delete">Destroy</a>

  - `button_to`: membuat form sederhana yang berisi sebuah submit button

            <%= button_to "New", action: "new" %>
            # => "<form method="post" action="/controller/new" class="button_to">
            #      <input value="New" type="submit" />
            #    </form>"

- FormHelper - Helper yang berkaitan dengan pembuatan form beserta field-fieldnya
  - Akan dijelaskan lebih lanjut di pembahasan berikutnya terkait form

### Menambahkan `link_to` ke layout
- di header tambahkan `link_to` di link logo mengarah ke `root_path`

        <!-- app/views/layouts/_header.html.erb -->
        <div class="navbar-header">
          <%= link_to 'Kostly', root_path, class: 'navbar-brand', id: 'logo' %>
        </div>

- di footer tambahkan `link_to` di link About mengarah ke `about_path`

        <!-- app/views/layouts/_footer.html.erb -->
        <nav>
          <ul>
            <li><%= link_to 'About', about_path %></li>
          </ul>
        </nav>

- `root_path` dan `about_path` adalah nama dari route kita yang bisa dilihat di <http://localhost:3000/rails/info/routes>
- atau bisa juga dilihat dengan menjalankan `rake routes` dari console
- dengan ini ketika kita mengakses <http://localhost:3000>, mengklik logo akan selalu membawa user ke homepage, sedangkan mengklik link about di footer akan membawa user ke halaman about

## Completing Home Page Template
- Setelah layouting selesai kita bisa kemudian menyelesaikan template kita

        <!-- app/views/static_pages/home.html.erb -->
        <% provide :title, 'Home' %>
        <div class="row">
          <div class="col-md-12 columns text-center">
            <img src="https://maps.googleapis.com/maps/api/staticmap?center=Yogyakarta,Indonesia&zoom=12&size=500x200&maptype=roadmap&scale=2">
          <hr>
          </div>
        </div>
        <div class="row">
          <% 8.times do %>
            <div class="col-md-3 columns place-item">
              <img src="http://placehold.it/200x150&text=Place%20Image" class="img-thumbnail">
              <h2>Place Name</h2>
              <p>Amet nunc urna dis. Diam odio pulvinar placerat pid! Phasellus arcu rhoncus massa. Ut arcu. Mus lectus rhoncus, in augue in aenean augue pellentesque, turpis lectus scelerisque tincidunt sagittis et, magna cum. Et mattis, sit montes, in ultricies urna elit, augue augue. Eu porttitor. Ridiculus, dis natoque turpis, ultricies eros.</p>
              <div class="pull-right">
                <img src="http://placehold.it/20x20">
                <small>By: Someone</small>
              </div>
            </div>
          <% end %>
        </div>

- Jangan lupa mengupdate about page juga

        <% provide :title, 'About' %>
        <h1>Tentang Kostly</h1>
        <p>Kostly adalah platform mencari rumah, kostan, atau tanah idaman anda</p>

**VOILA! Sekarang homepage kita selesai dan bisa di akses di <http://localhost:3000>**

## Referensi
- Github - Bootstrap-Sass - Ruby on Rails (<https://github.com/twbs/bootstrap-sass#a-ruby-on-rails>)
- Bootstrap - Components#Navbar (<http://getbootstrap.com/components/#navbar>)
- Bootstrap - CSS#Grid (<http://getbootstrap.com/css/#grid>)
- Rails Guide - Using Root (<http://guides.rubyonrails.org/routing.html#using-root>)
- Rails Guide - Using Partials (<http://guides.rubyonrails.org/layouts_and_rendering.html#using-partials>)
- Rails API - Text Helper (<http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html>)
- Rails API - Number Helper (<http://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html>)
- Rails API - Url Helper (<http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html>)
- Rails Guide - Form Helpers (<http://guides.rubyonrails.org/form_helpers.html>)
