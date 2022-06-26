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

(defn insert-recording [amount user-id contest-id]
  ```
  Inserting of recording.
  If we already find a similar recording for the same day,
  we update instead of inserting.
  ```
  (let [{:year-day year-day :year year } (os/date (os/time) :local)]
        (db/insert {:db/table :recording
                    :amount amount
                    :user_id user-id
                    :year year
                    :year_day year-day
                    :contest_id contest-id
                    } :on-conflict [:user_id :year :year_day]
                      :do :update :set { :amount amount }
                   )))

# TODO: make it one transaction
(defn create-user
  "Create a user within a contest.
  We also create a recording for the user to link the user to the given contest."
  [name contest-id]
  (def user (db/insert {:db/table :user :name name}))
  (insert-recording 0 (get user :id) contest-id))

(defn get-recordings
  [contest-id]
  (db/from :recording
           :where {:contest-id contest-id }))

(defn get-users
  [ids]
  (db/from :user
           :where {:id ids}))

(defn get-today-amount [contest-id user-id]
  "Get todays amount for given user"
  (try
    (let [{:year-day year-day :year year } (os/date (os/time) :local)]
      (-> (db/from :recording
               :where {:contest-id contest-id
                       :user-id user-id
                       :year year
                       :year-day year-day})
            (get 0)
            (get :amount)))
  ([err _] (do (pp err) 0))))

(defn get-user [id]
  (def users (get-users id))
  (if (empty? users)
    nil
    (get users 0)))

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

(defn- delete-recording
  "Just a helper function used in development"
  [id]
  (db/delete :recording id))

# (get-recordings 1)
# (delete-recording 2)

(defn- delete-contest
  "Just a helper function used in development"
  [id]
  (db/delete :contest id))

# (delete-contest 3)
