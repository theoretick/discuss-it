
const INITIAL_STATE = {
  status: "init",
  error: null,
  results: []
}

export default function(state = INITIAL_STATE, action) {
  switch(action.type) {
  case 'REQUEST_RESULTS':
    return {
      status: "pending",
      error: null,
      results: []
    }
  case 'RECEIVE_RESULTS':
    return {
      status: "done",
      error: null,
      results: action.payload.data
    }
  default:
    return state
  }
}
