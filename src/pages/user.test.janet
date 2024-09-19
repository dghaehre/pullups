(use judge)
(use joy)
(use ../test/setup)
(import ../storage :as st)
(use ./index)


(deftest: with-db "join contest endpoint" [_]
  (handler) # Creates routes
  (st/create-contest "test-contest")
  (st/create-user "myname" 1)
  (test (post/take-ownership {:body {:user-id 1
                                     :password "password"
                                     :username "something"}})
    @{:body " "
      :headers @{"Location" "/login"}
      :status 302})
  (def login-res (session/login {:body {:username "something"
                                        :password "password"}}))
  (test (get login-res :headers) @{"Location" "/private/user"})
  (test (get login-res :session)
    {:token "fef3e289-cab3-4aa6-96c4-79c2c0779c3a"
     :user-id 1})
  (test (-> (private/user {:body {:contest-name "test-contest"}
                           :session (get login-res :session)})
            (get 0)) # Only get header
    [:header
     [:div
      {:style "display: flex; justify-content: space-around;"}
      [:a {:style "width: 30px;"}]
      [:a
       {:href "/private/user"
        :style "color: var(--text); text-decoration: none;"}
       [:h3
        {:style "margin: 20px 0px -5px"}
        "myname"]]
      [:a
       {:class "logout"
        :href "/logout"
        :style "width: 30px; padding-top: 20px;"}
       "logout"]]]))
