(use joy)
(import json)

(defn- create-chart [data]
  (pp data)
  [:script (raw (string "
const test = " (json/encode data) ";
const labels = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
];

const data = {
  labels: labels,
  datasets: test,
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
  # (var labels [])
  (defn f [user]
    (var data (array/new 10)) # TODO: get capacity somehow
    (loop [r :in recordings :when (= (get user :id) (get r :user-id))]
      (do
        (def current-alltime (get user :alltime 0))
        (put user :alltime (+ current-alltime (get r :amount 0)))
        (array/push data (get r :amount 0))
        ))
    @{:label (get user :name)
      :backgroundColor "rgb(255, 99, 132)"
      :borderColor "rgb(255, 99, 132)"
      :data data })
  (map f users))

(defn overview [users recordings]
  [:div
   # TODO: use local chart.js
    [:script {:src "https://cdn.jsdelivr.net/npm/chart.js"}]
    [:canvas {:id "chart-overview"}]
    (create-chart (create-dataset users recordings))])

