(use joy)
(use utils)
(use ./utils)
(import ./storage :as st)


(route :post "/feedback" :feedback/index)


(defn- redirect [contest-id err]
  (let [status (if (nil? err)
                  {:feedback-success "Feedback received successfully"}
                  {:feedback-error err})]
    (if (nil? contest-id)
      (redirect-to :home/index {:? status})
      (let [contest (st/get-contest-from-id contest-id)]
        (redirect-to :contest/index {:contest (get contest :name) :? status})))))

(defn feedback/index [req]
  "Receive feedback info"
  (let [message (get-in req [:body :message])
        contest-id (get-in req [:body :contest])]
   (try
     (do
       (with-err "Could not store feedback" (st/insert-feedback message contest-id))
       (redirect contest-id nil))
     ([err _] (redirect contest-id err)))))
