(use joy)
(use ../utils)
(import ../storage :as st)
(import ./session :as s)
(import ./password :as p)

(defn validate-username [username]
  (cond
    (empty? username) (error "Username cannot be empty")
    (= "admin" username) (error "Username cannot be admin")
    (> 5 (length username)) (error "Username must be at least 5 characters long"))
  (let [[user-exists _] (protect (st/user-from-username username))]
    (if user-exists
      (error "Username already taken"))))

(defn make-private [id username password]
  "Make user private by providing a username and password"
  (validate-username username)
  (if (st/is-private? id)
    (error "User is already private"))
  (def password (p/secure-password password))
  (st/make-private id username password))

(defn record [user-id contest-id change-time contest-name amount &opt req]
  (if (st/is-private? user-id)
    (if (nil? (s/user-id-from-session req))
      (error "not allowed: user is private")
      (st/insert-recording amount user-id contest-id change-time))
    (st/insert-recording amount user-id contest-id change-time)))

