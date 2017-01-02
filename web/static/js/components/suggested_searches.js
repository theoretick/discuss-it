import React, { Component } from 'react'
import { connect } from 'react-redux'

import { requestResults, fetchResults } from '../actions'

const QUALIA_URL = "http://qualiacomputing.com/2015/05/22/how-to-secretly-communicate-with-people-on-lsd/"
const APPLE_URL = "http://www.apple.com/customer-letter"
const IMGUR_URL = "http://i.imgur.com/gOLvZVO.jpg"

class SuggestedSearches extends Component {
  render() {
    const { handleClick } = this.props

    return (
      <div>
        <h5>Suggested Searches:</h5>
        <p className="suggested">
          <a onClick={(e) => handleClick(e, QUALIA_URL)} href="#">
            How to secretly communicate with people on LSD - Qualia Computing
          </a>
        </p>
        <p className="suggested">
          <a onClick={(e) => handleClick(e, APPLE_URL)} href="#">
            A letter from Apple to all customers - apple.com
          </a>
        </p>
        <p className="suggested">
          <a onClick={(e) => handleClick(e, IMGUR_URL)} href="#">
            Photo of all-black house in Germany - imgur.com
          </a>
        </p>
      </div>
    )
  }
}

function mapStateToProps(state) {
  const { search: { status } } = state

  return { status }
}

function mapDispatchToProps(dispatch) {
  return {
    handleClick(e, link) {
      e.preventDefault();
      e.stopPropagation();

      dispatch(requestResults())
      dispatch(fetchResults(link))
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SuggestedSearches)
