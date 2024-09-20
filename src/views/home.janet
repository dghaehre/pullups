(use ./layout)

(def home-header
  [:header
    [:h2 "Daily pullups"]
    [:h4 "See if you can beat your friends"]])

(defn home-submit
  "Create competition button"
  [disabled]
  (let [attr @{:type "submit"}]
    (if disabled
      (put attr :disabled true))
    [:button (table/to-struct attr)
      [ "Create competition"]]))


(defn home-main [total-this-year logged-in? last-visisted-contest err]
  (assert (number? total-this-year) "total-today must be a number")
  (assert (boolean? logged-in?))
  (let [{:year year} (os/date (os/time) :local)]
    [:main {:style "text-align: center"}
     (when logged-in?
       [:a {:href "/private/user"}
           [:button "Your page"]])
     [:h3 "Create new competition"]
     [:form {:method "post" :action "/create-contest"}
      [:p
        [:input {:type "text"
                 :name "name"
                 :hx-get "/check-name"
                 :hx-trigger "keyup changed delay:200ms, load"
                 :hx-target "#submit"
                 :placeholder "Name of your group"}]]
      [:p {:id "submit" } (home-submit true)]
      [:p {:style "margin-top: 20px"}]
      [:p (string "See who can do the most pullups in " year)]
      (when (string? last-visisted-contest)
        [:div
         [:br]
         [:p "Last visisted: " [:a {:href (string "/" last-visisted-contest)} last-visisted-contest]]])
      [:hr]
      [:p {:style "margin-top: 100px"}]
      [:p (string total-this-year " recorded pullups so far in " year "!")]
      [:p "When you have created a name for your group, you can add participants."]
      [:p "Or " [:a {:href "/login"} "login"] " if you already have an account"]
      (if-not (nil? err) [notice-error err])]]))
