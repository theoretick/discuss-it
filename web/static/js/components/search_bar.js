import React, { Component } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { requestResults, fetchResults } from '../actions/index'

class SearchBar extends Component {
  constructor(props) {
    super(props)

    this.state = { search_term: '' }

    this.onFormSubmit = this.onFormSubmit.bind(this);
    this.onInputChange = this.onInputChange.bind(this);
  }

  onFormSubmit(event) {
    event.preventDefault();

    this.props.requestResults();
    this.props.fetchResults(this.state.search_term);
    this.setState({ search_term: '' });
  }

  onInputChange(event) {
    this.setState({ search_term: event.target.value })
  }

  render() {
    return (
      <form onSubmit={this.onFormSubmit} className="input-group">
        <input
        className="form-control"
        value={this.state.term}
        onChange={this.onInputChange} />
        <button type="submit" className="btn btn-secondary">Submit</button>
      </form>
    )
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ requestResults, fetchResults }, dispatch)
}


export default connect(null, mapDispatchToProps)(SearchBar)
