import React, { Component } from 'react'

import AboutThumbnailItem from './about_thumbnail_item'

const ABOUT_CONTRIBUTORS = [
  {
    username: 'theoretick',
    imgUrl: 'https://secure.gravatar.com/avatar/68a526b3e51ee3ed4c1d10e8b7fbd3c7?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png',
    githubUrl: 'https://github.com/theoretick'
  },
  {
    username: 'CodingAntecedent',
    imgUrl: 'https://secure.gravatar.com/avatar/81060418d41061aade8c8f7d74b584c4?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png',
    githubUrl: 'https://github.com/codingantecedent'
  },
  {
    username: 'ericalthatcher',
    imgUrl: 'https://secure.gravatar.com/avatar/7aa1140a4a9a313576971b9e74d9f90d?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png',
    githubUrl: 'https://github.com/ericalthatcher'
  }
]

class AboutThumbnailList extends Component {
  constructor(props) {
    super(props)

    this.state = {
      contributors: ABOUT_CONTRIBUTORS
    }
  }

  render() {
    const thumbnailItems = this.state.contributors.map((contributor) => {
      return (
        <AboutThumbnailItem key={contributor.username} contributor={contributor} />
      )
    })

    return (
      <ul className="row about-thumbnails">
        {thumbnailItems}
      </ul>
    )
  }
}

export default AboutThumbnailList
