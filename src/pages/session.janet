(use joy)
(use utils)
(use ../utils)
(import ../service/session :as s)

(route :get "/login" :get/login)
(route :post "/login" :session/login)
(route :get "/logout" :session/logout)


(defn- redirect-error [err]
  (redirect-to :get/login {:? {:error err}}))

(defn session/login [req]
  (try
    (let [username (get-in req [:body :username])
          password (get-in req [:body :password])
          {:token token :user-id user-id} (s/login username password)]
      (-> (htmx-redirect :private/user {:user-id user-id})
          (s/add-session token user-id)))
    ([err _] (redirect-error err))))
                       
(defn get/login [req]
  (let [err (get-in req [:query-string :error])]
    [:main
     [:h1 "Login"]
     [:form {:method "post" :action "/login"}
      [:input {:type "text" :name "username" :placeholder "Username"}]
      [:input {:type "password" :name "password" :placeholder "Password"}]
      [:input {:type "submit" :value "Login"}]]
     (when (not (nil? err))
       [:p {:class "error"} err])]))

(defn session/logout [req]
  (let [token (get-in req [:session :token])
        user-id (get-in req [:session :user-id])]
    (silent (s/logout user-id token))
    (-> (redirect-to :get/index)
      (put :session {}))))
