(use joy)
(use utils)
(use ../utils)
(import ../service/session :as s)
(import ../views/index :as view)

(defn- redirect-error [err]
  (redirect-to :get/login {:? {:error err}}))

(defn session/login [req]
  (try
    (let [username (get-in req [:body :username])
          password (get-in req [:body :password])
          {:token token :user-id user-id} (s/login username password)]
      (-> (redirect-to :private/user {:user-id user-id})
          (s/add-session token user-id)))
    ([err _] (redirect-error err))))
                       
(defn get/login [req]
  (let [err (get-in req [:query-string :error])]
    (view/login-main err)))

(defn session/logout [req]
  (let [token (get-in req [:session :token])
        user-id (get-in req [:session :user-id])]
    (silent (s/logout user-id token))
    (-> (redirect-to :home/index)
        (put :session {}))))
