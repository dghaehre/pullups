(use joy)

(defn contest-exist?
  "Check db if name already exist"
  [name]
  (not (empty? (db/from :contest :where {:name name} :limit 1))))

(defn create-contest
  [name]
  (db/insert {:db/table :contest :name name}))

(defn get-contest
  "Get contest. Returns nil if not found."
  [name]
  (def rows (db/from :contest :where {:name name}))
  (if (= 1 (length rows))
    (get rows 0)
    nil))

(defn insert-recording
  [amount user-id contest-id]
  (db/insert {:db/table :recording
              :amount amount
              :user_id user-id
              :contest_id contest-id}))

(defn create-user
  "Create a user within a contest.
  We also create a recording for the user to link the user to the given contest."
  [name contest-id]
  (def user (db/insert {:db/table :user
              :name name}))
  (insert-recording 0 (get user :id) contest-id))

(defn get-recordings
  [contest-id]
  (db/from :recording
           :where {:contest-id contest-id }))

(defn get-users
  [ids]
  (db/from :user
           :where {:id ids}))

# (get-users @[1 2])
# (get-recordings 1)
# (create-user "daniel" 1)
# (get-contest "testing")
# (contest-exist? "dsf")

# Seems like multiple joins are not supported by db/from
(defn- get-all
  "Just a helper function used in development"
  []
  (db/from :recording
           :join/one :user))

# (get-all)

(defn- delete-contest
  "Just a helper function used in development"
  [id]
  (db/delete :contest id))

# (delete-contest 3)
