import React, { Component } from 'react'

const AboutThumbnailItem = ({contributor}) => {
  var {username, imgUrl, githubUrl} = contributor

  return (
    <li className="col-md-4">
      <div className="thumbnail">
        <img src={imgUrl} />
        <div className="caption text-center">
          <h4>{username}</h4>
          <p align="center">
            <a className="btn btn-primary btn-block" href={githubUrl}>
              Github Profile
            </a>
          </p>
        </div>
      </div>
    </li>
  )
}

export default AboutThumbnailItem
