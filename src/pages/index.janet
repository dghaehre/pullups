# Export all pages/routes
(use joy)

(route :get "/" :home/index)
(route :get "/check-name" :home/checkname)
(route :post "/create-contest" :home/create-contest)

(route :get "/login" :get/login)
(route :post "/login" :session/login)
(route :get "/logout" :session/logout)


(route :get "/:contest" :contest/index)
(route :get "/:contest/get-chart" :contest/get-chart)

(route :post "/feedback" :feedback/index)

# User routes
# TODO: make more clean
(route :post "/take-ownership" :post/take-ownership)
(route :get "/take-ownership/:user-id" :get/take-ownership)
(route :get "/private/user" :private/user)
(route :get "/private/edit-contest/:id" :private/edit-contest)
(route :post "/private/edit-contest/:id" :post/edit-contest)
(route :get "/:contest/:user-id" :contest/user)
(route :post "/record" :contest/record)
(route :post "/create-user" :contest/create-user)
(route :get "/:contest/:user/get-record-form/:change" :contest/get-record-form)
(route :get "/get-record-form/:user/:change" :contest/get-record-form)
(route :post "/join-contest" :contest/join-contest)



(import ./session :prefix "" :export true)
(import ./home :prefix "" :export true)
(import ./contest :prefix "" :export true)
(import ./user :prefix "" :export true)
(import ./feedback :prefix "" :export true)
