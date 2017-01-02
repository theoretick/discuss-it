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
      <form onSubmit={this.onFormSubmit} className="form-horizontal">
        <div className="form-group">
          <label className="col-sm-2 control-label">Paste your link:</label>
          <div className="col-sm-10">
            <input
            className="form-control"
            placeholder="http://example.com/article.html"
            value={this.state.term}
            onChange={this.onInputChange}
            required='true' />
          </div>
        </div>
        <div className="form-group">
          <div className="col-sm-offset-2 col-sm-10">
            <button type="submit" className="btn btn-primary">Find Discussions</button>
          </div>
        </div>
      </form>
    )
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ requestResults, fetchResults }, dispatch)
}


export default connect(null, mapDispatchToProps)(SearchBar)
