(use joy)
(use utils)
(use ../utils)
(import ../storage :as st)
(import ../service/user :as user)
(import ../service/session :as s)

(route :post "/take-ownership" :post/take-ownership)
(route :get "/take-ownership/:user-id" :get/take-ownership)

(route :get "/private/user" :private/user)
(route :get "/private/edit-contest/:id" :private/edit-contest)
(route :post "/private/edit-contest/:id" :post/edit-contest)
(route :get "/:contest/:user-id" :contest/user)
(route :post "/record" :contest/record)
(route :post "/create-user" :contest/create-user)

(route :get "/:contest/:user/get-record-form/:change" :contest/get-record-form)
(route :get "/get-record-form/:user/:change" :contest/get-record-form)

(route :post "/join-contest" :contest/join-contest)

(defn- record-form [contest-name user-id current-amount &opt time change]
  "Where you record your daily stuff...

  If contest-name is nil, it will be a private user page
  "
  (assert (or (nil? contest-name) (string? contest-name)) "contest-name should be nil or string")
  (default time (os/time))
  (defn link [change-name]
    ```
    Supports multiple record endpoints
    - private user page
    - recording on contest path
    ```
    (assert (or (= change-name :yesterday)
                (= change-name :tomorrow)) "change-name should be yesterday or tomorrow")
    (let [new-change (case [change change-name]
                       [:yesterday :tomorrow] "today"
                       [:tomorrow :yesterday] "today"
                       (string change-name))]
      (if (nil? contest-name)
        (string "/get-record-form/" user-id "/" new-change)
        (string "/" (cname contest-name) "/" user-id "/get-record-form/" new-change))))


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
                  :hx-get (link :yesterday)
                  :hx-target "#record-form"}
           "⬅"])
        [:span {:style "color: grey; margin: 0px;"} (string day "/" m "/" year)]
        (if (= change :tomorrow)
          empty-arrow
          [:span {:style "margin-left: 10px;"
                  :class "date-arrow"
                  :hx-trigger "click"
                  :hx-get (link :tomorrow)
                  :hx-target "#record-form"}
           "➡"])]
      [:p
        [:input {:type "text" :placeholder current-amount :name "amount"}]]
      (when (string? contest-name)
        [:input {:type "hidden" :name "contest-name" :value contest-name}])
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
       [:h3 [:a {:href (string "/private/user")} (get user :name)]]
       [:h3 (get user :name)])
     [:hr]

     (when (not (nil? err))
       [:p {:style "color: red;"} err])

     (cond
       (and public-user? logged-in-different-user?)
       [:div
         [:div {:id "record-form"} (record-form (get contest :name) (get user :id) (get user :today))]
         [:p "You are logged in as a different user. Since this is a public user, you can still record pullups."]]

       (and (not public-user?) logged-in-different-user?)
       [:div
           [:p "This user is private"]
           [:p "You do not have permission to record pullups for this user."]]

       (and public-user? (not logged-in-user?))
       [:div
         [:div {:id "record-form"} (record-form (get contest :name) (get user :id) (get user :today))]
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
         [:div {:id "record-form"} (record-form (get contest :name) (get user :id) (get user :today))]]

       [:div # Ups, this should never happen! But I have this as a fallback
         [:div {:id "record-form"} (record-form (get contest :name) (get user :id) (get user :today))]])]))
  

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
        user        (st/get-user user-id)
        time        (time-by-change (keyword change))
        today       (st/get-today-amount user-id time)]
    (text/html (record-form name user-id today time (keyword change)))))

(defn contest/user [req]
  (let [err                 (get-in req [:query-string :error])
        contest-name        (get-in req [:params :contest])
        user-id             (get-in req [:params :user-id])
        contest             (st/get-contest contest-name)
        logged-in-userid?   (s/user-id-from-session req)]
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

(defn contest/record [req]
  (let [user-id       (get-in req [:body :user-id])
        change        (get-in req [:body :change])
        contest-name  (get-in req [:body :contest-name]) # optional
        redirect      (fn [&opt err]
                        (let [e (if (nil? err) {} {:? {:error err}})]
                          (if (nil? contest-name)
                            (redirect-to :private/user e)
                            (redirect-to :contest/user (merge {:contest (cname contest-name) :user-id user-id} e)))))]
    (try
      (let [amount (with-err "Not a valid number" (int/to-number (int/u64 (get-in req [:body :amount]))))]
        (user/record user-id (time-by-change (keyword change)) amount req)
        (redirect))
      ([err] (redirect err)))))

(s/defn-auth contest/join-contest [req user-id]
  (let [contest-id    (as-> (get-in req [:body :contest-id]) ?
                            (with-err "Not a valid contest id" (int/to-number (int/u64 ?))))
        contest-name  (get-in req [:body :contest-name])]
    (assert (and (string? contest-name)
                 (not (= contest-name ""))))
    (assert (not= user-id (get-in req [:body :user-id])))
    (st/join-contest user-id contest-id)
    (redirect-to :contest/index {:contest (cname contest-name)})))

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
  (let [user     (st/get-user user-id)
        contests (st/get-contests-by-user user-id)
        today    (st/get-today-amount user-id (time-by-change :today))]
    [ (header-private (user :name))
      [:main
       [:p "This is your private user page"]
       [:table {:style "display: inline-table; margin: 0;" :class "contest-table"}
        [:thead
         [:tr
          [:th "Your contests"]
          [:th "Todays ranking"]]]
        [:tbody
          (seq [{:name name :id id} :in contests]
            (let [{:rank rank :participants p :no-recordings nr} (st/get-todays-ranking id user-id)]
              [:tr
               [:td [:a {:href (string "/" name)} name]]
               [:td (display-ranking rank p nr)]]))]]
       [:br]
       [:p "Record"]
       [:div {:id "record-form"} (record-form nil user-id today)]]]))

(s/defn-auth private/edit-contest [req user-id]
  (let [user (st/get-user user-id)
        contest-id (get-in req [:params :id])
        err        (get-in req [:query-string :error])
        contest    (st/get-contest-from-id contest-id)]
    (if (nil? contest)
      (redirect-to :home/index)
      [ (header-private (user :name))
        [:main
         [:h3 "Edit contest"]
         [:p "This is where you can edit the contest"]
         (if (not (nil? err))
           [:p {:style "color: red;"} err]
           [:br])
         [:form {:action (string "/private/edit-contest/" contest-id)
                 :method "post"
                 :style "max-width: 500px;"}
          [:input {:type "hidden" :name "contest-id" :value contest-id}]
          [:p
            [:label "Contest name"]
            [:input {:type "text" :name "name" :value (get contest :name)}]]
          [:p
           [:label
             [:input {:type "checkbox" :name "private"}] # TODO
             "Private contest"]]
          [:details 
           [:summary "Start and end date"]
           [:div
             [:p "When you create a contest it will not have a start date or end date. If you want you can add these dates here."]
             [:p
                [:label "Start date"]
                [:input {:type "date" :name "start-date" :value (get contest :start-date)}]]
             [:p
               [:label "End date"]
               [:input {:type "date" :name "end-date" :value (get contest :end-date)}]]]]
          [:br]
          [:button {:type "submit"} "Update"]]]])))

(s/defn-auth post/edit-contest [req user-id]
  (let [name       (get-in req [:body :name])
        # start-date (get-in req [:body :start-date]) TODO
        # end-date   (get-in req [:body :end-date]) TODO
        contest-id (get-in req [:params :id])]
    (try
      (do
        (when (not (available-contest-name? name))
          (error "Invalid or contest name already exists"))
        (st/update-contest contest-id name)
        (redirect-to :private/edit-contest {:id contest-id}))
      ([err] (redirect-to :private/edit-contest {:id contest-id :? {:error err}})))))
    

(comment
  (time-by-change :someth))
