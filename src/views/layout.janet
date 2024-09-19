
(def notice-error :p.notice.error.slide-in-animation)
(def notice :p.notice.slide-in-animation)

(defn header-private
  [name]
  [:header
    [:div {:style "display: flex; justify-content: space-around;"}
      [:a {:style "width: 30px;"}]
      [:a {:href "/private/user"
           :style "color: var(--text); text-decoration: none;"}
        [:h3 {:style "margin: 20px 0px -5px"} name]]
      [:a {:class "logout" :style "width: 30px; padding-top: 20px;"
           :href "/logout"} "logout"]]])

(defn header-private-contest
  [contest-name]
  [:header
    [:div {:style "display: flex; justify-content: space-around;"}
      [:a {:style "width: 100px;"}]
      [:a {:href (string "/" contest-name)
           :style "color: var(--text); text-decoration: none;"}
        [:h3 {:style "margin: 20px 0px -5px"} contest-name]]
      [:a {:class "logout" :style "width: 100px; padding-top: 20px;"
           :href "/private/user"} "your page"]]])

(defn header
  [contest-name &opt logged-in?]
  (if logged-in?
    (header-private-contest contest-name)
    [:header
      [:a {:href (string "/" contest-name)
           :style "color: var(--text); text-decoration: none;"}
        [:h3 {:style "margin: 20px 0px -5px"} contest-name]]]))

(defn footer [req &opt contest-id]
  (let [success     (get-in req [:query-string :feedback-success])
        err         (get-in req [:query-string :feedback-error])]
    [:footer
      (if-not (nil? success)
        [notice success])
      (if-not (nil? err)
        [notice-error err])
     [:p {:style "text-align: center"}
       [:span "Made by "]
       [:a {:href "https://dghaehre.com"} "Daniel"]
       [:span " using "]
       [:a {:href "https://janet-lang.org"} "Janet"]]
     [:p
       [:form {:method "post" :action "/feedback"}
        [:p "For feedback or requests:"]
        (if-not (nil? contest-id)
          [:input {:type "hidden"
                   :name "contest"
                   :value contest-id}])
        [:p [:input {:type "text"
                     :name "message"
                     :placeholder ""}]]
        [:button {:style "margin: 0px; padding: 8px;"} "Send feedback"]]]]))

