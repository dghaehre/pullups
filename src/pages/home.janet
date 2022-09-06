(use joy)
(use ../utils)
(import ../storage :as st)

(def- home/header
  [:header
    [:h2 "A pullups competition" ]
    [:h4 "See if you can beat your friends"]])

(defn- submit
  "Create competition button"
  [disabled]
  (def attr @{:type "submit" })
  (if disabled
    (put attr :disabled true))
  [:button (table/to-struct attr)
    [ "Create competition" ]])

(defn- main [err]
  [:main {:style "text-align: center"}
     [:h3 "Create a competition"]
     [:form {:method "post" :action "/create-contest"}
      [:p
        [:input {:type "text"
                 :name "name"
                 :hx-get "/check-name"
                 :hx-trigger "keyup changed delay:200ms, load"
                 :hx-target "#submit"
                 :placeholder "Some wierd name"}]]
      [:p {:id "submit" } (submit true)]
    (if-not (nil? err) (display-error err))]])


# Routes

(route :get "/" :home/index)
(route :get "/check-name" :home/checkname)
(route :post "/create-contest" :home/create-contest)

(defn home/checkname
  "Check if name is available"
  [req]
  (def name (get-in req [:query-string :name]))
  (def available (and (valid-contest-name? name) (not (st/contest-exist? name))))
  (text/html (submit (not available))))

(defn home/create-contest
  "Create contest"
  [req]
  (def name (get-in req [:body :name]))
  (try
    (do
      (with-err "could not create contest" (st/create-contest name))
      (redirect-to :contest/index {:contest name}))
    ([err _] (redirect-to :home/index { :? {:error err }}))))


(defn home/index
  "Home screen
  Let user create a new 'contest'"
  [req]
  (let [err (get-in req [:query-string :error])]
    [ home/header
     (main err)
     footer ]))
