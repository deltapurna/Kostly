## Belajar Rails Session 7
# LOGIN AND RESET PASSWORD FUNCTIONALITY

Link Heroku:
<https://belajarrails2.herokuapp.com>

Link Github:
<https://github.com/deltapurna/Kostly/commits/master>

## Rails Authentication
- proses login esensinya adalah memastikan seorang user adalah orang yang benar-benar user tersebut
- kita bisa menggunakan sebuah kata kunci untuk tujuan ini
- tapi kita tidak boleh menyimpan kata kunci sebagai _plain text_ di database
- jika kita sudah berhasil meng-autentikasi seorang user, kita bisa menandai request dari user ini sehingga requestnya terhitung sebagai request dari seorang yang sudah login

### Menggunakan `has_secure_password`
- method bawaan dari rails untuk menyimpan _password_ secara secure di database
- method ini bisa di tambahkan di model yang membutuhkan
- dalam konteks aplikasi kita, kita perlu menambahkan di model `User`
- method ini mengasumsikan modelnya memiliki kolom bernama `password_digest` di tabel
- method ini kemudian akan melakukan 3 hal:
  + menambahkan __virtual__ (tidak ada kolom ini di tabel) atribut dan validasi untuk `password` dan `password_confirmation`
  + secara otomatis akan menggunakan `bcrypt` untuk meng-hash `password` untuk disimpan sebagai `password_digest` di database
  + menambahkan method `authenticate`:
      * `user.authenticate('correctpassword') # return the user if password correct`
      * `user.authenticate('wrongpassword') # return false if password is wrong`

### Menambahkan secure password to model `User`
- tambahkan kolom `password_digest` ke tabel `users` 
  + `bin/rails generate migration AddPasswordDigestToUsers password_digest:string`
  + jalankan dengan `bin/rake db:migrate`
- tambahkan gem `bcrypt` ke Gemfile
  
        # Gemfile
        gem 'bcrypt', '~> 3.1.7'

- tambahkan `has_secure_password` method

        # app/models/user.rb
        class User < ActiveRecord::Base
          ...
          has_secure_password
          ...
        end

- kita bisa mencobanya di console

        # bin/rails console
        user = User.new
        user.password_digest
          => nil
        user.password = 'mypassword'
        user.password_digest
          => "$2a$10$ot.QTuSW3LAWVs9K32rJ3eGWT7QhLMTnRARUHFDVYQTJVW/F/YoTK"
        user.authenticate('mypassword')
          => #<User id: nil, name: nil, email: nil,... ">
        user.authenticate('wrongpassword')
          => false

### Menggunakan sessions untuk menandai user yang sudah login
- http ada sebuah protocol yang stateless
- dengan menggunakan sessions kita bisa menciptakan state di http request
- session menyerupai hash, key-value pair:
  + `sessions[:user_id] = user.id # set session`
  + `sessions[:user_id] # get session value`
  + `sessions[:user_id] = nil # set to nil (for log out process)`

### Sessions as resources (login is create session, logout is destroy session)
- `bin/rails generate controller sessions new`
- update routes:

        # config/routes.rb
        Rails.application.routes.draw do
          ...
          get 'sign_in', to: 'sessions#new'
          delete 'sign_out', to: 'sessions#destroy'
          ...
          resources :sessions
          ...
        end

- update views:

        <!-- app/views/sessions/new.html.erb -->
        <h2>Sign In</h2>
        <%= form_tag :sessions do %>
          <div class='form-group'>
            <%= label_tag :email %>
            <%= text_field_tag :email, '', class: 'form-control' %>
          </div>
          <div class='form-group'>
            <%= label_tag :password %>
            <%= password_field_tag :password, '', class: 'form-control' %>
          </div>
          <%= submit_tag 'Sign In', class: 'btn btn-primary btn-block' %>
        <% end %>

- update controller to handle login and logout logic:

        # app/controllers/sessions_controller.rb
        class SessionsController < ApplicationController
          def new
          end

          def create
            # 1. find user by the email
            user = User.find_by(email: params[:email])
            if user && user.authenticate(params[:password])
              # 2. if the user exist and the password correct, set the session
              session[:user_id] = user.id
              redirect_to user_url(user), notice: 'Signed in successfully!'
            else
              # 3. else back to login form
              redirect_to sign_in_url, alert: 'Wrong email or password'
            end
          end

          def destroy
            # to logout simply nullify the session
            session[:user_id] = nil
            redirect_to root_url, notice: 'Signed out successfully!'
          end
        end

- mendeteksi user yang sudah login menggunakan session
  + kita letakkan di `application_controller.rb` sehingga bisa diakses di semua controller
  + kita deklarasikan sebagai helper juga menggunakan `helper_method` method sehingga bisa digunakan di views

            # app/controllers/application_controller.rb
            class ApplicationController < ActionController::Base
              ...
              helper_method :user_logged_in?, :current_user

              def current_user
                @current_user ||= User.find_by(id: session[:user_id])
              end

              def user_logged_in?
                current_user
              end
            end

- sekarang kita bisa mengupdate navigasi kita menyesuaikan apakah user sudah login atau belum (menggunakan `current_user` dan `user_logged_in?` methods)

        <!-- app/views/layouts/_header.html.erb -->
        <nav class="navbar navbar-default navbar-static-top">
          <div class="container">
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
              <ul class="nav navbar-nav navbar-right">
                <% if user_logged_in? %>
                  <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Hi <%= current_user.name %> <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                      <li><%= link_to 'Edit Profile', edit_user_path(current_user) %></li>
                      <li class="divider"></li>
                      <li><%= link_to 'Sign Out', sign_out_path, method: :delete %></li>
                    </ul>
                  </li>
                <% else %>
                  <li><%= link_to 'Sign In', sign_in_path %></li>
                  <li><%= link_to 'Sign Up', sign_up_path %></li>
                <% end %>
              </ul>
            </div><!-- /.navbar-collapse -->
          </div><!-- /.container-fluid -->
        </nav>


## Rails Authorizations
- sekarang setelah berhasil melakukan authentication, kita bisa melakukan authorization
- authorization artinya kita mengontrol akses yang bisa dilakukan oleh seorang user

### Hanya logged in `User` yang bisa membuat `Place` baru
- buat sebuah method di `application_controller.rb` (agar bisa di akses di semua controller)
  + method ini akan meredirect user ke login form jika belum login

            # app/controllers/application_controller.rb
            class ApplicationController < ActionController::Base
              ...
              def authorize
                unless user_logged_in?
                  redirect_to sign_in_url,
                    alert: 'You are not authorized! Please login first!'
                end
              end
            end

- panggil method ini di controller yang ingin kita autorisasi menggunakan `filter`
  + controller filter adalah method yang bisa kita panggil sebelum, setelah atau ketika mengeksekusi sebuah action
  + dalam case ini kita ingin memanggil method `authorize` untuk semua action di `places_controller` kecuali `index` dan `show`

            # app/controllers/places_controller.rb
            class PlacesController < ApplicationController
              before_action :authorize, except: [:index, :show]
              ...
            end

- **VOILA!** sekarang hanya user yang sudah login yang bisa membuat dan mengedit tempat
- kita bisa mencegah user lebih lanjut di view menggunakan helper yang sudah kita buat

        <!-- app/views/places/index.html.erb -->
        <h1>Listing Places</h1>
        <% if user_logged_in? %>
          <%= link_to 'Add Place', new_place_path, class: 'btn btn-primary' %>
        <% end %>
        ...
              <td width='30%'>
                <div class='btn-group'>
                  <%= link_to 'View', place_path(place), class: 'btn btn-default' %>
                  <% if user_logged_in? %>
                    <%= link_to 'Edit', edit_place_path(place), class: 'btn btn-default' %>
                    <%= link_to 'Delete', place_path(place), class: 'btn btn-default', method: :delete, data: { confirm: 'Are you sure?' } %>
                  <% end %>
                </div>
              </td>
        ...

### `Place` hanya bisa di edit oleh `User` pemiliknya
**HOMEWORK**

### `User` profile hanya bisa di edit oleh `User` itu sendiri
**HOMEWORK**

## Sending Reset Password Email
### Create mailer
- built in with rails
- generate mailer with the generator `bin/rails g mailer user_mailer reset_password`
  + this will generate the mailer,
  + the test (with preview)
  + and the text & html email template
- mailer is like controller. but instead of using render, we user mail method to send email
- like in controller, we can pass variable from mailer to view template with instance variable

        # app/mailers/user_mailer.rb
        class UserMailer < ApplicationMailer
          def reset_password(user_id)
            @user = User.find(user_id)
            mail to: @user.email, subject: 'Password Reset Instructions'
          end
        end

### Create password reset controller
- generate with controller generator
  `bin/rails g controller password_resets`
- this is a good example that sometimes controller not necessarily tight to a particular model
- it can be used to handle a specific function
- for example password reset:
  + new: to display form to get email to send reset password instruction to
  + create: the contain the logic to generate token and send email
  + edit: to display the form to update password (authenticate with token generated before)
  + update: to contain the logic to update user model with the new password

### Updating `password_resets_controller.rb` to call the mailer
- we can call mailer from this controller

        # app/controllers/password_resets_controller.rb
        class PasswordResetsController < ApplicationController
          ...
          def create
            user = User.find_by(email: params[:email])
            if user
              user.set_reset_password_token
              UserMailer.reset_password(user.id).deliver_later
              redirect_to root_url, notice: 'Please check your email'
            else
              redirect_to new_password_reset_url, alert: 'Email not found in our system'
            end
          end
        end

- note: password reset function menggunakan token untuk autentikasi dari link di email
- code untuk me-generate token sebagai berikut:

        # app/models/user.rb
        class User < ActiveRecord::Base
          ...
          def set_reset_password_token
            self.reset_password_token = loop do
              token = SecureRandom.hex
              break token unless self.class.exists?(reset_password_token: token)
            end
            save!
          end
        end

### Updating email template
- by default rails mensupport text dan html email
- template untuk text email:

        <%# app/views/user_mailer/reset_password.text.erb %>
        Password Reset Instructions

        Hi <%= @user.name %>,

        Please go to this url to edit your password:
        <%= edit_password_reset_url(@user, token: @user.reset_password_token) %>

- template untuk html email:

        <%# app/views/user_mailer/reset_password.text.erb %>
        <h1>Password Reset Instructions</h1>

        <h2>Hi <%= @user.name %>,</h2>

        <p>Please click the following link to edit your password:
        <%= link_to 'Reset your password', edit_password_reset_url(@user, token: @user.reset_password_token) %></p>

### Setting SMTP configuration
- in rails we can configure SMTP for each environment
- sample for gmail:

          # config/environments/development.rb (or in test.rb or in production.rb)
          config.action_mailer.default_url_options = { host: 'localhost:3000' }
          config.action_mailer.delivery_method = :smtp
          config.action_mailer.smtp_settings = {
            address:              'smtp.gmail.com',
            port:                 587,
            domain:               'example.com',
            user_name:            'your-email@gmail.com',
            password:             'your-secret-password-here',
            authentication:       'plain',
            enable_starttls_auto: true  }

- in heroku can use some addons for email, like sendgrid
  heroku addons:add sendgrid
- then add the configuration in production

          # config/environments/production.rb
          config.action_mailer.raise_delivery_errors = true
          config.action_mailer.delivery_method = :smtp
          host = '<your-heroku-app-name>.herokuapp.com'
          config.action_mailer.default_url_options = { host: host }
          ActionMailer::Base.smtp_settings = {
            address: 'smtp.sendgrid.net',
            port: '587',
            authentication: :plain,
            user_name: ENV['SENDGRID_USERNAME'],
            password: ENV['SENDGRID_PASSWORD'],
            domain: 'heroku.com',
            enable_starttls_auto: true
          }

- **HOMEWORK** Buat controller actions dan views untuk reset password dan edit password serta logic untuk update password (new, edit & update action)

## Referensi
- Rails API - Secure Password (<http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html>)
- Rails Guide - About Session (<http://guides.rubyonrails.org/action_controller_overview.html#session>)
- Rails Guide - Controller Filter (<http://guides.rubyonrails.org/action_controller_overview.html#filters>)
- Rails Guide - Action Mailer Basics (<http://guides.rubyonrails.org/action_mailer_basics.html>)
- Rails Guide - Action Mailer for Gmail (<http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail>)
