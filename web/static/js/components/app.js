import React, { Component } from 'react';
import SearchBar from './search_bar'
import ResultList from './result_list'

export default class App extends Component {
  render() {
    return (
      <div className="jumbotron jumbotron-cta">
        <h1>Discuss It!</h1>
        <p className="cta">
          Online discussion tracker for finding conversations
        </p>
        <SearchBar />
        <ResultList />
      </div>
    )
  }
}
