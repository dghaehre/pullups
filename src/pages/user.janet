(use joy)
(use utils)
(use ../utils)
(import ../storage :as st)

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
     [:form {:method "post" :action "/record" }
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
        [:input {:type "text" :placeholder current-amount :name "amount"} ]]
      [:input {:type "hidden" :name "contest-id" :value (get contest :id) } ]
      [:input {:type "hidden" :name "contest-name" :value (get contest :name) } ]
      [:input {:type "hidden" :name "year" :value year } ]
      [:input {:type "hidden" :name "month-day" :value md } ]
      [:input {:type "hidden" :name "change" :value change } ]
      [:input {:type "hidden" :name "user-id" :value user-id } ]
      [:p 
        [:button {:type "submit"} "Update" ]]]))

(defn- layout
  [user contest err]
  [:main
   [:h3 (get user :name) ]
   [:hr]
   [:div {:id "record-form"} (record-form contest (get user :id) (get user :today))]
   (if-not (nil? err) (display-error err))])

(defn contest/create-user
  [req]
  (def name (get-in req [:body :name]))
  (def contest-id (get-in req [:body :contest-id]))
  (def contest-name (get-in req [:body :contest-name]))
  (if (-> name (string/trim) (empty?))
    (redirect-to :contest/index {:contest (cname contest-name)
                                 :? {:error "empty user name" }})
    (do
      (st/create-user name contest-id)
      (redirect-to :contest/index {:contest contest-name }))))

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
        contest       (st/get-contest contest-name)]
    (if (nil? contest)
      (redirect-to :home/index)
      (let [user (st/get-user-from-contest (get contest :id) user-id)]
        (if (nil? user)
          (redirect-to :contest/index {:contest (cname contest-name)})
          (do
            (put user :today (st/get-today-amount user-id))
            [ (header contest-name)
              (layout user contest err)
              (footer req (get contest :id)) ]))))))

(defn contest/record
  [req]
  (let [user-id       (get-in req [:body :user-id])
        contest-id    (get-in req [:body :contest-id])
        change        (get-in req [:body :change])
        contest-name  (get-in req [:body :contest-name])]
    (try
      (let [amount (with-err "Not a valid number" (int/to-number (int/u64 (get-in req [:body :amount]))))]
        (pp change)
        (st/insert-recording amount user-id contest-id (time-by-change (keyword change)))
        (redirect-to :contest/index {:contest (cname contest-name) }))

      ([err fib]
        (redirect-to :contest/user { :contest (cname contest-name)
                                    :user-id user-id
                                    :? {:error err }})))))
