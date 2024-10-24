(use ../utils)

(defn user-record-form [contest-name user-id current-amount &opt time change]
  "Where you record your daily stuff...

  If contest-name is nil, it will be a private user page
  "
  (assert (or (nil? contest-name) (string? contest-name)) "contest-name should be nil or string")
  (default time (os/time))

  # TODO: move link function out
  (defn link [change-name]
    ```
    Supports multiple record endpoints
    - private user page
    - recording on contest path
    ```
    (assert (or (= change-name :yesterday
                  (= change-name :tomorrow)) "change-name should be yesterday or tomorrow"))
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
