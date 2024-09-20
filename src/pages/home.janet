(use joy)
(use utils)
(use ../utils)
(import ../service/general :as g)
(import ../service/contest :as c)
(import ../service/session :as s)
(import ../storage :as st)
(import ../views/index :as view)

(defn home/checkname
  "Check if name is available"
  [req]
  (def name (get-in req [:query-string :name]))
  (def available (g/available-contest-name? name))
  (text/html (view/home-submit (not available))))

(defn home/create-contest
  "Create contest"
  [req]
  (def name (get-in req [:body :name]))
  (try
    (do
      (with-err "could not create contest" (c/create-contest name))
      (redirect-to :contest/index {:contest (cname name)}))
    ([err _] (redirect-to :home/index { :? {:error err}}))))

(defn home/index
  "Home screen
  Let user create a new 'contest'"
  [req]
  (let [err (get-in req [:query-string :error])
        logged-in? (not (nil? (s/user-id-from-session req)))
        last-visisted-contest (s/get-last-visited req)]
    [ view/home-header
     (view/home-main (st/total-this-year) logged-in? last-visisted-contest err)
     (view/footer req)]))
