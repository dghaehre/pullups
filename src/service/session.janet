(use joy)
(import ../storage :as st)
(import ./password :as pw)
(import uuid)

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
  (put res :session {:token token :user-id user-id})
  res)

(defn logout [user-id token]
  (st/delete-session user-id token))
