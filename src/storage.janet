(use joy)
(use utils)
(use ./utils)

(defn contest-exist?
  "Check db if name already exist"
  [name]
  (let [rows (db/query `
              select * from contest
              where upper(name) = upper(:name)` {:name (from-cname name)})]
    (not (nil? (get rows 0)))))

(defn create-contest
  [name]
  (db/insert {:db/table :contest :name name}))

(defn get-contest
  "Get contest. Returns nil if not found."
  [name]
  (let [rows (db/query `
              select * from contest
              where upper(name) = upper(:name)` {:name (from-cname name)})]
    (get rows 0)))

(defn get-contest-from-id [id]
  (db/find :contest id))

(defn get-contests
  "Get all contests"
  []
  (db/from :contest))

(defn get-contests-by-user [user-id]
  "Get all contests for a user"
  (db/query `
   select c.id, c.name from contest c
   inner join mapping m on m.contest_id = c.id
   where m.user_id = :userid` {:userid user-id}))

(defn insert-feedback [message &opt contest-id]
  (db/insert {:db/table :feedback
              :message message
              :contest_id contest-id}))

(defn get-feedbacks []
  (db/from :feedback))

(defn insert-recording [amount user-id &opt time]
  ```
  Inserting of recording.
  If we already find a similar recording for the same day,
  we update instead of inserting.
  ```
  (default time (os/time))
  (let [{:year-day year-day :year year } (os/date time :local)]
       (db/insert {:db/table :recording
                   :amount amount
                   :user_id user-id
                   :year year
                   :year_day year-day}
                  :on-conflict [:user_id :year :year_day]
                     :do :update :set { :amount amount})))
                   
(defn total-this-year []
  ```
  All total recordings for this year
  ```
  (let [{:year year } (os/date (os/time) :local)
        rows (db/query `
               select
               SUM(amount) as total
               from recording
               where year = :year` {:year year})]
      (-> (get rows 0)
          (get :total 0))))

# TODO: make it one transaction
(defn create-user
  "Create a user within a contest.
  We also create a recording for the user to link the user to the given contest."
  [name contest-id]
  (let [user (db/insert {:db/table :user :name name})]
    (db/insert {:db/table :mapping
                :user_id (get user :id)
                :contest_id contest-id})))

(defn get-users
  [ids]
  (db/from :user
           :where {:id ids}))

(defn get-user-from-contest [contest-id user-id]
  (let [rows (db/query `
              select u.id, u.name, u.username, u.password from user u
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

(defn get-today-amount [user-id &opt time]
  "Get todays amount for given user

  Returns 0 if no recording is found.
  "
  (default time (os/time))
  (let [{:year-day year-day :year year } (os/date time :local)]
    (or (-?> (db/from :recording
                      :where {:user-id user-id
                                   :year year
                                   :year-day year-day})
             (get 0)
             (get :amount))
        0)))

(defn get-todays-ranking [contest-id user-id]
  (let [now (os/time)
        {:year year :year-day year-day} (os/date now :local)
        rows (db/query `
               with users as (
                              select * from user
                              inner join mapping on mapping.user_id = user.id
                              and mapping.contest_id = :id)
               , recordings as (
                                select * from recording
                                inner join users on users.id = recording.user_id
                                where year = :year
                                and year_day = :year_day)
               , todays as (
                            select
                            amount,
                            user_id
                            from recordings
                            where year = :year
                            and year_day = :year_day
                            group by user_id)
               select
                 u.id,
                 u.name,
                 coalesce(t.amount, 0) as today
                 -- rank() over (order by t.amount desc) as rank
               from users u
               left join todays t on t.user_id = u.id
               order by today desc
               ` {:id contest-id
                  :year year
                  :year_day year-day})]
    {:rank (with-err "Could not calculate ranking for this user"
             (->> rows
                  (map |(get $ :id))
                  (index-of user-id)
                  (+ 1)))
     :participants (length rows)
     :no-recordings (->> rows
                         (map |(get $ :today))
                         (reduce2 +)
                         (= 0))}))

(comment
  (get-todays-ranking 2 2))
  
 

(defn contents-stats [contest-id]
  ```
 Returns the users in the given contest with:
 - todays amount
 - total amount THIS YEAR
 - total amount THIS MONTH
 ```
  (let [now (os/time)
        {:year year :year-day year-day} (os/date now :local)
        start-of-month (to-beginning-of-month now)]
    (db/query `
      with users as (
                     select * from user
                     inner join mapping on mapping.user_id = user.id
                     and mapping.contest_id = :id)
      , recordings as (
                       select * from recording
                       inner join users on users.id = recording.user_id)
      , totals as (
                   select
                   SUM(amount) as total,
                   user_id
                   from recordings
                   where year = :year
                   group by user_id)
      , todays as (
                   select
                   amount,
                   user_id
                   from recordings
                   where year = :year
                   and year_day = :year_day
                   group by user_id)
      , month as (
                  select
                  SUM(amount) as total,
                  user_id
                  from recordings
                  where created_at > :month
                  group by user_id)
      , topscore as (
                     select
                     MAX(amount) as topscore,
                     user_id
                     from recordings
                     where year = :year
                     group by user_id)
      
      select
        u.id,
        u.name,
        coalesce(t.total, 0) as total,
        coalesce(m.total, 0) as month,
        coalesce(d.amount, 0) as today,
        coalesce(s.topscore, 0) as topscore
      from users u
      left join totals t on t.user_id = u.id
      left join todays d on d.user_id = u.id
      left join month m on m.user_id = u.id
      left join topscore s on s.user_id = u.id
      order by today DESC
      ` {:id contest-id
         :year year
         :month start-of-month
         :year_day year-day})))

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
    recording.created_at,
    (recording.year_day + recording.year) as i
   from recording
    left join user on user.id = recording.user_id
    inner join mapping on mapping.user_id = recording.user_id
    and mapping.contest_id = :id
    and recording.year = :year
    order by recording.created_at DESC` {:id contest-id
                                         :year year}))

(defn get-chart-data-month [contest-id]
  `
  Get recordings with user data for current month.
  `
  (let [start-of-month (to-beginning-of-month (os/time))]
    (db/query `
     select
      user.id as id,
      user.name,
      recording.amount,
      recording.year,
      recording.year_day,
      recording.created_at,
      (recording.year_day + recording.year) as i
     from recording
      left join user on user.id = recording.user_id
      inner join mapping on mapping.user_id = recording.user_id
      and mapping.contest_id = :id
      and recording.created_at > :time
      order by recording.created_at DESC` {:id contest-id
                                           :time start-of-month})))

(defn get-user [id]
  (def users (get-users id))
  (if (empty? users)
    nil
    (get users 0)))

(defn is-private? [id]
  (def user (get-user id))
  (if (nil? user)
    (error (string "No user found with id: " id)))
  (and (not (nil? (get user :username)))
       (not (nil? (get user :password)))))
  
(defn make-private [id username password]
  (db/update :user {:id id} {:username username :password password}))

(defn user-from-username [username]
  (let [users (db/from :user :where {:username username})]
    (if (empty? users)
      (error "No user found with that username")
      (get users 0))))

(defn join-contest [user-id contest-id]
  (assert (number? user-id))
  (assert (number? contest-id))
  (db/query `
   insert into mapping (user_id, contest_id)
   values (:user_id, :contest_id)` {:user_id user-id :contest_id contest-id}))

(defn insert-session [user-id token]
  (assert (number? user-id))
  (assert (string? token))
  (db/insert {:db/table :session
              :user_id user-id
              :token token}
            :on-conflict [:user_id]
               :do :update :set {:token token}))

(defn delete-session [token user-id]
  (db/delete :session {:user_id user-id :token token}))

(defn session-valid? [token user-id]
  (let [row (-> (db/from :session :where {:user_id user-id :token token})
                (get 0))]
    (not (nil? row))))

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
