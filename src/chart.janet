(use joy)
(import json)

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

#
# TODO: this is not finished. It needs to take into considerations the other users data.
# At some points/labels it might be needed to use 0
(defn create-dataset [users recordings]
  ```Create data for chart.js

  Example:
  datasets: [{
    label: 'My First dataset',
    backgroundColor: 'rgb(255, 99, 132)',
    borderColor: 'rgb(255, 99, 132)',
    data: [0, 10, 5, 2, 20, 30, 45],
  }]
  ```
  (defn f [user]
    (var data @[]) # TODO: get capacity somehow
    (loop [r :in recordings :when (= (get user :id) (get r :user-id))]
      (do
        (def current-alltime (get user :alltime 0))
        (put user :alltime (+ current-alltime (get r :amount 0)))
        (array/concat data (get r :amount 0))))
    @{:label (get user :name)
      :backgroundColor "rgb(255, 99, 132)"
      :borderColor "rgb(255, 99, 132)"
      :data data })
  (map f users))

(defn create-labels [recordings]
  @["Monday" "Tuesday" "Wednesday"])

(defn overview [users recordings]
  (def data (create-dataset users recordings))
  (def labels (create-labels recordings))
  [:div
   # TODO: use local chart.js
    [:script {:src "https://cdn.jsdelivr.net/npm/chart.js"}]
    [:canvas {:id "chart-overview"}]
    (create-chart data labels)])

