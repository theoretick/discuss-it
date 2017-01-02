
const INITIAL_STATE = {
  status: "init",
  error: null,
  results: []
}

export default function(state = INITIAL_STATE, action) {
  switch(action.type) {
  case 'REQUEST_RESULTS_SUBMIT':
    return {
      status: "pending",
      error: null,
      results: []
    }
  case 'FAIL_RESULTS_SUBMIT':
    return {
      status: "fail",
      error: action.payload.data,
      results: []
    }
  case 'RECEIVE_RESULTS_SUBMIT':
    return {
      status: "done",
      error: null,
      results: action.payload.data
    }
  default:
    return state
  }
}
