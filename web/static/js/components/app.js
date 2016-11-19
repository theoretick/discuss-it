import React, { Component } from 'react';
import SearchBar from './search_bar'
import ResultList from './result_list'

export default class App extends Component {
  render() {
    return (
      <div>
        <SearchBar />
        <ResultList />
      </div>
    )
  }
}
