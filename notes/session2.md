## Belajar Rails Session 2
# STATIC PAGES

Link Heroku:
<https://belajarrails2.herokuapp.com/home>

Link Github:
<https://github.com/deltapurna/Kostly/commit/cdfe5fc2a347d56e5e4b46f76b9ceed7b262414a>

## Inisiasi rails app baru: Kostly
- `rails new kostly`
- `cd kostly`
- `bin/rails server`
- kunjungi <http://localhost:3000>

## Basic Routing: Bagaimana flow request dari browser hingga rails menampilkan response?
**Objective: Ketika user mengunjungi <http://localhost:3000/home>, user akan dibawa ke halaman welcome page**

_Error 1: No route matches [GET] '/home'_

- bisa dibaca: rails tidak tahu bagaimana menghandle url `/home` ini karena belum didefinisikan di route config file.
- solusi: definisikan routing `/home`

### Mendefinisikan Routing
- Routing di rails di definikan di sebuah file config `config/routing.rb`
- file `config/routing.rb` punya 2 tugas:
    - mapping dari url menjadi controller & action
    - mapping dari controller & action menjadi string url
- `get 'home' => 'static_pages#home'`
- atau bisa juga:
- `get 'home', to: 'static_pages#home'`
- format: `<http verb: misalnya get,post dll.> <nama url>, to: <nama controller (snake case)>#<nama action>`

_Error 2: uninitialized constant StaticPagesController_

- bisa dibaca: OK, rails sekarang tau kalau `/home` harus di bawa ke controller bernama `static_pages`, tapi rails tidak bisa menemukan controller yang di maksud.
- solusi: buat controller yang dimaksud

### Membuat Controller Pertama: StaticPagesController
- menggunakan generator controller
- `bin/rails generate controller static_pages`
    - => will generate `static_pages_controller.rb` in `app/controllers` folder
    - dan beberapa file test dan assets

_Error 3: The action 'home' could not be found for StaticPagesController_

- bisa dibaca: OK, rails sudah bisa menemukan controller `static_pages`, tapi action `home` belum didefinisikan di controller ini
- solusi: buat action `home` di controller `static_pages`

### Membuat Action di Controller: Home
- controller pada esensinya hanyalah sebuah ruby class biasa
- `class StaticPagesController < ApplicationController`
- semua controller yang kita buat harus menginherit dari base controller yaitu `ApplicationController`
- action yang dimaksud juga esensinya adalah sebuah method di class controller

        # app/controllers/static_pages_controller.rb
        def home
        end

_Error 4: Missing template static_pages/home

- bisa dibaca: OK, rails menemukan `home` action, karena action ini tidak ada **explicit rendering** rails mengasumsikan default rendering dengan template `home.html` di folder `app/views/static_pages`. Tapi template tersebut tidak bisa ditemukan.
- solusi: buat template view di folder `app/views/static_pages` dengan nama file sesuai nama action (home)

### Membuat View Template
- buat secara manual sebuah file dengan nama `home.html` di folder `app/views/static_pages`

        <!-- app/views/static_pages/home.html -->
        <h1>Hello World</h1>

**VOILA! Sekarang mengakses <http://localhost:3000/home> akan memberikan kita halaman Hello World!**
**TUGAS: Buat halaman About dengan step yang sama seperti di atas!**

## Basic Assets: Bagaimana bisa menstyle halaman kita dengan CSS?
- semua assets (css, js, images) di rails bisa di letakkan di folder `app/assets`
- rails by default punya 1 css file ketika membuat project rails di `app/assets/stylesheets`
- file ini adalah file manifest yang juga berfungsi menggabungkan css-css lainnya di folder ini
- file ini namanya `application.css`

        /* app/assets/stylesheets/application.css */
        h1 {
          color: blue;
        }

- sekarang mengakses halaman `/home` di server kita akan menampilkan 'Hello World' berwarna biru :)

## Basic Layouting: Di mana tag `<html>` dan `<body>` ?
- rails secara default menggunakan sistem layouting untuk memudahkan menampilkan view html
- template di sebuah aplikasi rails disimpan di folder `app/views/layouts`
- secara default ada 1 layout file dengan nama `application.html.erb`


        <!DOCTYPE html>
        <html>
          ...
        <body>
        
        <%= yield %>
        
        </body>
        </html>

- disinilah di definisikan tag html, body dan lainnya
- template yang kita definisikan di `home.html` di masukkan oleh rails ke dalam layout di mana ada method `yield`
- secara default setiap controller akan mencari file layout sesuai dengan nama controllernya (`static_pages.html.erb`) di folder `app/views/layouts`
- jika controller layout ini tidak di temukan maka akan beralih ke template default `application.html.erb` di folder `app/views/layouts`
- hal ini bisa di override di controller level maupun di setiap controller action dengan secara explicit menyebutkan layout yang ingin digunakan

        # app/controllers/static_pages_controller.rb
        def about
          render layout: 'pages'
        end

## Basic Dynamic Page: Embed Kode Ruby dan Memberikan Value dari Controller ke View

### Embedded RuBy (ERB)
- Untuk memasukkan kode ruby ke view kita, kita perlu menggunakan bahasa templating dari rails
- secara default rails menggunakan erb sebagai templating (bisa diganti ke yang lain jika diperlukan)
- cukup merubah file `home.html` kita menjadi `home.html.erb` maka kita sudah bisa memasukkan kode ruby ke dalam html kita
- erb menggunakan syntax `<% %>` dan `<%= %>`
- `<% %>` digunakan untuk menuliskan kode ruby tanpa di print ke halaman html kita (bisa untuk loop atau conditional logic)
- `<%= %>` digunakan untuk memprint kode ruby ke dalam halaman html kita. Misalnya untuk menampilkan value dari sebuah variabel.

### Menggunakan instance variable `@variable_name` untuk mengakses value di controller dari view
- dengan mudah kita bisa memberikan value dari controller ke view dengan instance variable
- instance variable dibuat dengan menambahkan ampersand (`@`) di awal nama variabel.

        # app/controller/static_pages_controller.rb
        def home
          @name = 'Delta'
        end

- kemudian variable `@name` akan bisa di akses melalui erb template kita

        <!-- app/views/static_pages/home.html.erb -->
        <h1>Hello <%= @name %></h1>

- sekarang kita akan melihat 'Hello Delta' ketika kita mengakses `/home`

## Basic Params: Menangkap Value Parameter dari Sebuah Request di Controller
**Objective: Ketika user mengunjungi <http://localhost:3000/home?name=Delta>, user akan dibawa ke halaman welcome page dan melihat 'Hello Delta'**

- kita bisa mendapatkan semua parameter dari sebuah request di controller maupun view dengan menggunakan method `params`
- params adalah sebuah `hash` object (key value pair)
- kita bisa mengakses value dari sebuah key dengan syntax `params[:key_name]`
- dalam kasus kali ini kita perlu mengakses value dari key `name`, maka syntaxnya: `params[:name]`

        # app/controller/static_pages_controller.rb
        def home
          @name = params[:name]
        end

- seperti dijelaskan sebelumnya karena kita menyimpan value `params[:name]` ke dalam sebuah instance variable `@name`, maka view kita juga bisa mengaksesnya
- dan seperti sebelumnya mengakses <http://localhost:3000/home?name=Delta> akan menampilkan 'Hello Delta'
- tapi sekarang secara dinamis kita bisa merubah nilai name melalui get parameter kita

## Referensi
- Rails Guide - Rails Routing from the Outside In (<http://guides.rubyonrails.org/routing.html>)
- Rails Guide - Layouts and Rendering in Rails (<http://guides.rubyonrails.org/layouts_and_rendering.html>)
- Rails Guide - Action Controller Overview (<http://guides.rubyonrails.org/action_controller_overview.html#parameters>)
