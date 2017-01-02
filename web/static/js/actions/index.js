import axios from 'axios'

export function requestResults() {
  return {
    type: "REQUEST_RESULTS_SUBMIT",
    payload: null
  }
}

export function fetchResults(query_url) {
  const request = axios.get(`/api/submit?url=${query_url}`);

  return {
    type: "RECEIVE_RESULTS_SUBMIT",
    payload: request
  }
}
