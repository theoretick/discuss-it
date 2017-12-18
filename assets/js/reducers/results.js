
const INITIAL_STATE = {
  status: "init",
  error: null,
  results: []
}

export default function(state = INITIAL_STATE, action) {
  switch(action.type) {
  case 'REQUEST_RESULTS_SUBMIT':
    return {
      ...state,
      status: "pending",
      error: null
    }
  case 'FAIL_RESULTS_SUBMIT':
    return {
      ...state,
      status: "fail",
      error: action.payload.data
    }
  case 'RECEIVE_RESULTS_SUBMIT':
    return {
      ...state,
      status: "done",
      error: null,
      results: action.payload.data
    }
  default:
    return state
  }
}
