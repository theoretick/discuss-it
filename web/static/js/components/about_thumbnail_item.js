import React, { Component } from 'react'

const AboutThumbnailItem = ({ contributor }) => {
  var { username, imgUrl, githubUrl } = contributor

  return (
    <li className="col-md-4">
      <div className="thumbnail">
        <a href={githubUrl}>
          <img src={imgUrl} />
          <div className="caption text-center">
            <h4>{username}</h4>
          </div>
        </a>
      </div>
    </li>
  )
}

export default AboutThumbnailItem
