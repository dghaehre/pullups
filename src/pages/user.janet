(use joy)
(use utils)
(use ../utils)
(import ../storage :as st)
(import ../service/user :as user)
(import ../service/session :as s)

(route :post "/take-ownership" :post/take-ownership)
(route :get "/take-ownership/:user-id" :get/take-ownership)

(route :get "/user/:user-id" :private/user)
(route :get "/:contest/:user-id" :contest/user)
(route :post "/record" :contest/record)
(route :post "/create-user" :contest/create-user)
(route :get "/:contest/:user/get-record-form/:change" :contest/get-record-form)

(defn- record-form [contest user-id current-amount &opt time change]
  "Where you record your daily stuff..."
  (default time (os/time))
  (defn new-change [c]
    (case [change (keyword c)]
      [:yesterday :tomorrow] "today"
      [:tomorrow :yesterday] "today"
      c))
  (let [{:year year :month m :month-day md} (os/date time :local)
        day                                 (+ 1 md)
        empty-arrow [:span {:style "margin-right: 12px; margin-left: 12px;" :class "date-arrow"} "   "]]
     [:form {:method "post" :action "/record"}
      [:p
        [:label [:h4 "Total pullups"]]]
      [:p
        (if (= change :yesterday)
          empty-arrow
          [:span {:style "margin-right: 10px;"
                  :class "date-arrow"
                  :hx-trigger "click"
                  :hx-get (string "/" (cname (get contest :name)) "/" user-id "/get-record-form/" (new-change "yesterday"))
                  :hx-target "#record-form"}
           "⬅"])
        [:span {:style "color: grey; margin: 0px;"} (string day "/" m "/" year)]
        (if (= change :tomorrow)
          empty-arrow
          [:span {:style "margin-left: 10px;"
                  :class "date-arrow"
                  :hx-trigger "click"
                  :hx-get (string "/" (get contest :name) "/" user-id "/get-record-form/" (new-change "tomorrow"))
                  :hx-target "#record-form"}
           "➡"])]
      [:p
        [:input {:type "text" :placeholder current-amount :name "amount"}]]
      [:input {:type "hidden" :name "contest-id" :value (get contest :id)}]
      [:input {:type "hidden" :name "contest-name" :value (get contest :name)}]
      [:input {:type "hidden" :name "year" :value year}]
      [:input {:type "hidden" :name "month-day" :value md}]
      [:input {:type "hidden" :name "change" :value change}]
      [:input {:type "hidden" :name "user-id" :value user-id}]
      [:p 
        [:button {:type "submit"} "Update"]]]))

(defn- layout
  [user contest logged-in-userid? err]
  (print err)
  (let [public-user? (and (nil? (user :username)) (nil? (user :password)))
        logged-in-user?           (and (not (nil? logged-in-userid?)) (= logged-in-userid? (user :id)))
        logged-in-different-user? (and (not (nil? logged-in-userid?)) (not logged-in-user?))
        private-no-access?        (and (not public-user?) (not logged-in-user?))]
    [:main
     (if logged-in-user?
       [:h3 [:a {:href (string "/user/" (user :id))} (get user :name)]]
       [:h3 (get user :name)])
     [:hr]

     (when (not (nil? err))
       [:p {:style "color: red;"} err])

     (cond
       (and public-user? logged-in-different-user?)
       [:div
         [:div {:id "record-form"} (record-form contest (get user :id) (get user :today))]
         [:p "You are logged in as a different user. Since this is a public user, you can still record pullups."]]

       (and (not public-user?) logged-in-different-user?)
       [:div
           [:p "This user is private"]
           [:p "You do not have permission to record pullups for this user."]]

       (and public-user? (not logged-in-user?))
       [:div
         [:div {:id "record-form"} (record-form contest (get user :id) (get user :today))]
         [:p "This user is not owned"
            [:br]
            [:a {:href (string "/take-ownership/" (get user :id))} "Take ownership"]]]

       (and (not public-user?) (not logged-in-user?))
       [:div
           [:p "This user is private"]
           [:p "You do not have permission to record pullups for this user."]
           [:a {:href (string "/login")} "Maybe you need to log in?"]]

       logged-in-user?
       [:div
         [:div {:id "record-form"} (record-form contest (get user :id) (get user :today))]]

       [:div # Ups, this should never happen! But I have this as a fallback
         [:div {:id "record-form"} (record-form contest (get user :id) (get user :today))]])]))
  

(defn- private-form [user]
   [:h4 "Do you want to claim this user?"]
   [:form {:method "post" :action "/take-ownership"}
    [:input {:type "text" :name "username" :placeholder "username"}]
    [:input {:type "password" :name "password" :placeholder "password"}]
    [:input {:type "hidden" :name "user-id" :value (get user :id)}]
    [:br]
    [:button {:type "submit"} "Claim"]])

(defn contest/create-user
  [req]
  (def name (get-in req [:body :name]))
  (def contest-id (get-in req [:body :contest-id]))
  (def contest-name (get-in req [:body :contest-name]))
  (if (-> name (string/trim) (empty?))
    (redirect-to :contest/index {:contest (cname contest-name)
                                 :? {:error "empty user name"}})
    (do
      (st/create-user name contest-id)
      (redirect-to :contest/index {:contest (cname contest-name)}))))

# TODO; handle error
(defn contest/get-record-form [req]
  (let [name        (get-in req [:params :contest])
        user-id     (get-in req [:params :user])
        change      (get-in req [:params :change])
        contest     (st/get-contest name)
        user        (st/get-user-from-contest (get contest :id) user-id)
        time        (time-by-change (keyword change))
        today       (st/get-today-amount user-id time)]
    (text/html (record-form contest user-id today time (keyword change)))))

(defn contest/user
  [req]
  (let [err           (get-in req [:query-string :error])
        contest-name  (get-in req [:params :contest])
        user-id       (get-in req [:params :user-id])
        contest       (st/get-contest contest-name)
        logged-in-userid?    (s/user-id-from-session req)]
    (if (nil? contest)
      (redirect-to :home/index)
      (let [user (st/get-user-from-contest (get contest :id) user-id)]
        (if (nil? user)
          (redirect-to :contest/index {:contest (cname contest-name)})
          (do
            (put user :today (st/get-today-amount user-id))
            [ (header contest-name logged-in-userid?)
              (layout user contest logged-in-userid? err)
              (footer req (get contest :id))]))))))

(defn contest/record
  [req]
  (let [user-id       (get-in req [:body :user-id])
        contest-id    (get-in req [:body :contest-id])
        change        (get-in req [:body :change])
        contest-name  (get-in req [:body :contest-name])]
    (try
      (let [amount (with-err "Not a valid number" (int/to-number (int/u64 (get-in req [:body :amount]))))]
        (user/record user-id contest-id (time-by-change (keyword change)) contest-name amount req)
        (redirect-to :contest/index {:contest (cname contest-name)}))

      ([err fib]
       (redirect-to :contest/user {:contest (cname contest-name)
                                   :user-id user-id
                                   :? {:error err}})))))

(defn get/take-ownership [req]
  (let [user-id (get-in req [:params :user-id])
        user (st/get-user user-id)
        is-private (or (not (nil? (user :username))) (not (nil? (user :password))))]
    (when is-private # TODO: better way of handling this case
      (error "Cannot take ownership of a private user"))
    [ (header "user name")
      [:main
        [:h3 "Taking ownership of " (user :name)]
        [:p "By providing a username and password to an existing user, you can claim ownership of that user. This means that only you can update the user's information and record pullups for the user."]
        [:p "You will also be able to use the same user for multiple contests."]
        [:br]
        (private-form {:id user-id})]]))

(defn post/take-ownership [req]
  (let [user-id (get-in req [:body :user-id])
        password (get-in req [:body :password])
        username (get-in req [:body :username])]
    (user/make-private user-id username password)
    (redirect-to :get/login)))

(s/defn-auth private/user [req user-id]
  (let [user (st/get-user user-id)]
    [ (header-private (user :name))
      [:main
       [:p "This is a private user page"]
       [:p "Your user-id: " user-id]
       [:p "Your contests:"]
       [:p "Record pullups (for alle coontests)"]
       [:p "Change name and password"]]]))

(comment
  (time-by-change :someth))
