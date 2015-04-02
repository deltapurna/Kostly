## Belajar Rails Session 2
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
## Referensi
- Rails Guide - Resource Routing (<http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default>)
