(use joy)
(import json)
(import ./common :as common)
(import ./storage :as st)

# TODO: fix labels

(defn- create-chart [data labels]
  [:script (raw (string "
const data = {
  labels: " (json/encode labels) ",
  datasets: " (json/encode data) ",
};

const config = {
  type: 'line',
  data: data,
  options: {}
};

const myChart = new Chart(
  document.getElementById('chart-overview'),
  config
);"))])

(defn- year-day-data [user recordings]
  ```
  Return a map of amount where key is :year-day + :year
  ```
  (var data @{})
  (loop [r :in recordings :when (= (get user :id) (get r :user-id))]
    (put data (+ (get r :year) (get r :year-day)) (get r :amount 0)))
  data)

# Dette er problemet med dynamic typing. Dette hadde vært sååå mye lettere i haskell!

# TODO: this is not finished. It needs to take into considerations the other users data.
# At some points/labels it might be needed to use 0
(defn create-dataset [users recordings]
  ```Create data for chart.js

  Returns @[{
    label: 'My First dataset',
    backgroundColor: 'rgb(255, 99, 132)',
    borderColor: 'rgb(255, 99, 132)',
    data: [0, 10, 5, 2, 20, 30, 45],
  }]
  ```
  # TODO: year-data is an array, count for that!
  (def year-data (map |(year-day-data $0 recordings) users))
  (assert (array? year-data))

  (pp year-data)
  (def start-day (min (splice (keys year-data))))
  (def end-day (max (splice (keys year-data))))
  (pp start-day)
  (pp end-day)
  (def data-length (- start-day end-day))
  (pp data-length))

  # (defn- create-user-dataset [user]
  #   (var data (array/new data-length))
  #   # How does this looping works..?
  #   # (loop [d :in year-data :when (= (get user :id) (get d :user-id))]
  #   #   (for i 0 data-length
  #   #     # TODO
  #   #     (array/insert data i (get d i 0))))
  #   @{:label (get user :name)
  #     :backgroundColor "rgb(255, 99, 132)"
  #     :borderColor "rgb(255, 99, 132)"
  #     :data data })
  # (map create-user-dataset users))

# (defn test []
#   (def id 1)
#   (def recordings (st/get-recordings id))
#   (def user-ids (common/unique-user-ids recordings))
#   (def users (st/get-users user-ids))
#   (def year-data (map |(year-day-data $0 recordings) users))
#   (create-dataset users recordings))
# (test)

(defn create-labels [data recordings]
  @["Monday" "Tuesday" "Wednesday"])

(defn overview [users recordings]
  (def data (create-dataset users recordings))
  (def labels (create-labels data recordings))
  [:div
   # TODO: use local chart.js
    [:script {:src "https://cdn.jsdelivr.net/npm/chart.js"}]
    [:canvas {:id "chart-overview"}]
    (create-chart data labels)])

