(use ./layout)

(defn login-main [err]
  [:main
   [:h1 "Login"]
   [:form {:method "post" :action "/login"}
    [:input {:type "text" :name "username" :placeholder "Username"}]
    [:input {:type "password" :name "password" :placeholder "Password"}]
    [:input {:type "submit" :value "Login"}]]
   (when (not (nil? err))
     [notice-error err])])
