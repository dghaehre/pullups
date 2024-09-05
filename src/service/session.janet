(use joy)
(use judge)
(import ../storage :as st)
(import ./password :as pw)
(import uuid)

(defn add-last-visited [res req contest-name]
  (assert (string? contest-name))
  (let [session (get req :session {})]
    (merge res {:session (merge session {:last-visited contest-name})})))

(test (-> {:body "body"
           :session {:token "hey"}}
        (add-last-visited  {} "contest"))
  @{:body "body"
    :session @{:last-visited "contest"}})

(defn get-last-visited [req]
  (get-in req [:session :last-visited]))

(defn login [username password]
  (assert (string? username) "Not a valid username")
  (assert (string? password) "Not a valid password")
  (let [user (st/user-from-username username)]
    (if (not (pw/verify-password password (get user :password)))
      (error "invalid password"))
    (let [token (uuid/new)]
      (st/insert-session (get user :id) token)
      {:token token :user-id (get user :id)})))

(defn add-session [res token user-id]
  (assert (string? token))
  (assert (number? user-id))
  (merge res {:session {:token token :user-id user-id}}))


(defn logout [user-id token]
  (st/delete-session token user-id))

(defmacro defn-auth
  "Define a function that requires authentication.

  Usage:
  (defn-auth some-handler [req user-id]
    body)"
  [name params & body]
  ~(defn ,name [req]
    (let [token         (get-in req [:session :token])
          user-id       (get-in req [:session :user-id])
          [success valid]         (protect (,st/session-valid? token user-id))]
       (if (and success valid)
         ((fn ,params (do ,;body)) req user-id)
         (redirect-to :get/login)))))

(defn user-id-from-session [req]
  "Get the user-id from the session, or nil if the session is invalid."
  (let [token         (get-in req [:session :token])
        user-id       (get-in req [:session :user-id])
        [success valid]         (protect (st/session-valid? token user-id))]
    (if (and success valid)
      user-id
      nil)))

(comment

  # Goal
  (defn-auth testing [req user-id]
    [:h1 "yessda"])

  (testing {:session {:token "test"}})

  (macex1 '(defn-auth testing [req user-id]
            [:h1 "yessda"])))
