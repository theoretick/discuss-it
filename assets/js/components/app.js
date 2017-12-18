import React, { Component } from 'react';
import SearchBar from './search_bar'
import ResultList from './result_list'
import SuggestedSearches from './suggested_searches'

export default class App extends Component {
  render() {
    return (
      <div>
        <div className="jumbotron jumbotron-cta">
          <h1>Discuss It!</h1>
          <p className="cta">
            Online discussion tracker for finding conversations
          </p>
          <SearchBar />
          <ResultList />
        </div>
        <div className="well">
          <SuggestedSearches />
        </div>
      </div>
    )
  }
}
