(use joy)
(use utils)
(use ../utils)
(import ../service/general :as g)
(import ../storage :as st)

(def- home/header
  [:header
    [:h2 "Daily pullups"]
    [:h4 "See if you can beat your friends"]])

(defn- submit
  "Create competition button"
  [disabled]
  (let [attr @{:type "submit"}]
    (if disabled
      (put attr :disabled true))
    [:button (table/to-struct attr)
      [ "Create competition"]]))

(defn- main [err]
  (let [{:year year} (os/date (os/time) :local)]
    [:main {:style "text-align: center"}
     [:h3 "Create new competition"]
     [:form {:method "post" :action "/create-contest"}
      [:p
        [:input {:type "text"
                 :name "name"
                 :hx-get "/check-name"
                 :hx-trigger "keyup changed delay:200ms, load"
                 :hx-target "#submit"
                 :placeholder "Name of your group"}]]
      [:p {:id "submit" } (submit true)]
      [:p {:style "margin-top: 100px"}]
      [:p (string "See who can do the most pullups in " year)]
      [:p "When you have created a name for your group, you can add participants"]
      (if-not (nil? err) (display-error err))]]))

# Routes

(route :get "/" :home/index)
(route :get "/check-name" :home/checkname)
(route :post "/create-contest" :home/create-contest)

(defn home/checkname
  "Check if name is available"
  [req]
  (def name (get-in req [:query-string :name]))
  (def available (g/available-contest-name? name))
  (text/html (submit (not available))))

(defn home/create-contest
  "Create contest"
  [req]
  (def name (get-in req [:body :name]))
  (try
    (do
      (with-err "could not create contest" (st/create-contest name))
      (redirect-to :contest/index {:contest (cname name)}))
    ([err _] (redirect-to :home/index { :? {:error err}}))))


(defn home/index
  "Home screen
  Let user create a new 'contest'"
  [req]
  (let [err (get-in req [:query-string :error])]
    [ home/header
     (main err)
     (footer req)]))

(comment
  (main nil))
