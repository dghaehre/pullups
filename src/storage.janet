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

(defn get-contests
  "Get all contests"
  []
  (db/from :contest))

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
                    } :on-conflict [:user_id :year :year_day]
                      :do :update :set { :amount amount }
                   )))

# TODO: make it one transaction
(defn create-user
  "Create a user within a contest.
  We also create a recording for the user to link the user to the given contest."
  [name contest-id]
  (let [user (db/insert {:db/table :user :name name})]
    (db/insert {:db/table :mapping
                :user_id (get user :id)
                :contest_id contest-id})))

(defn get-recordings [contest-id]
  ```
  Get all recordings from a contest
  ```
  (db/from :recording
           :where {:contest-id contest-id }))

(defn get-users
  [ids]
  (db/from :user
           :where {:id ids}))

(defn get-user-from-contest [contest-id user-id]
  (let [rows (db/query `
  select u.id, u.name from user u
  inner join mapping m
  on u.id = m.user_id
  and u.id = :userid
  and m.contest_id = :contestid` {:contestid contest-id :userid user-id})]
    (get rows 0 nil)))

(defn get-users-from-contest [contest-id]
  (db/query `
  select u.id, u.name from user u
  inner join mapping m
  on u.id = m.user_id
  and m.contest_id = :contestid` {:contestid contest-id}))

# TODO: remove
(defn get-today-amount [user-id]
  "Get todays amount for given user"
  (try
    (let [{:year-day year-day :year year } (os/date (os/time) :local)]
      (or (-?> (db/from :recording
                        :where {:user-id user-id
                                :year year
                                :year-day year-day})
               (get 0)
               (get :amount))
          0))
    ([err _] (do (pp err) 0))))

(defn contents-stats [contest-id]
  ```
 Returns the users in the given contest with todays amount and
 total amount THIS YEAR
 ```
  (def {:year year :year-day year-day} (os/date (os/time) :local))
  (db/query `
    with users as (
      select * from user
      inner join mapping on mapping.user_id = user.id
      and mapping.contest_id = :id
    ), recordings as (
      select * from recording
      inner join users on users.id = recording.user_id
    ), totals as (
      select
        SUM(amount) as total,
        user_id
      from recordings
      where year = :year
      group by user_id
    ), todays as (
      select
        amount,
        user_id
      from recordings
      where year = :year
      and year_day = :year_day
      group by user_id
    ), topscore as (
      select
        MAX(amount) as topscore,
        user_id
      from recordings
      where year = :year
      group by user_id
    )

    select
      u.id,
      u.name,
      coalesce(t.total, 0) as total,
      coalesce(d.amount, 0) as today,
      coalesce(s.topscore, 0) as topscore
    from users u
    left join totals t on t.user_id = u.id
    left join todays d on d.user_id = u.id
    left join topscore s on s.user_id = u.id
    order by total DESC

    ` {:id contest-id
       :year year
       :year_day year-day}))

(defn get-chart-data [contest-id &opt year]
  `
  Get recordings with user data.
  Only for one year.
  `
  (default year (get (os/date (os/time) :local) :year))
  (db/query `
  select
    user.id as id,
    user.name,
    recording.amount,
    recording.year,
    recording.year_day,
    (recording.year_day + recording.year) as i
  from recording
    left join user on user.id = recording.user_id
    inner join mapping on mapping.user_id = recording.user_id
    and mapping.contest_id = :id
    and recording.year = :year
    order by recording.created_at DESC` {:id contest-id
                                         :year year}))

(defn get-user [id]
  (def users (get-users id))
  (if (empty? users)
    nil
    (get users 0)))

# Seems like multiple joins are not supported by db/from
(defn- get-all
  "Just a helper function used in development"
  []
  (db/from :recording
           :join/one :user))

(defn delete-recording
  "Just a helper function used in development"
  [id]
  (db/delete :recording id))

(defn delete-contest
  "Just a helper function used in development"
  [id]
  (db/delete :contest id))
