import React, { Component } from 'react'
import { connect } from 'react-redux'

class ResultList extends Component {

  sortByScore(results) {
    return results.sort((a,b) => {
      if (a.score > b.score) {
        return -1;
      } else if (a.score < b.score) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  renderResultRow(result_data) {
    return (
      <tr key={result_data.location}>
        <td>{result_data.site}</td>
        <td>
          <a href={result_data.location}>
            {result_data.title}
          </a>
        </td>
        <td>{result_data.score}</td>
      </tr>
    )
  }

  render() {
    if (this.props.status === "init") {
      return (
        <div></div>
      )
    } else if (this.props.status === "pending") {
      return (
        <div className="loader">Loading...</div>
      )
    } else if (this.props.status == "done" && this.props.all_results.length === 0) {
      return (
        <div>No Results</div>
      )
    }

    return (
      <div>
        <table className="table" id="other-discussions-table">
          <thead>
            <tr>
              <th className="listing-metadata"></th>
              <th className="listing-link"></th>
              <th className="listing-score"></th>
            </tr>
          </thead>
          <tbody>
            {this.sortByScore(this.props.all_results).map(this.renderResultRow)}
          </tbody>
        </table>
      </div>
    )
  }
}

function mapStateToProps({ search }) {
  const results = search.results

  return {
    status: search.status,
    all_results: results.all_results,
    top_results: results.top_results
  }
}

export default connect(mapStateToProps)(ResultList)
