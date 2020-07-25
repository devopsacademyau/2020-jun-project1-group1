[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

# Moving a WordPress-based application from on-premise to a cloud-hosted solution

<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
  * [Solution Diagram](#solution-diagram)
  * [Technologies](#technologies)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)


## About The Project
This project aims to move a web application from on-premise to a cloud-hosted solution.

Currently, the WordPress-based application uses LAMP stack (Linux, Apache, MySQL, and PHP) and the solution is hosted in a single server (application and database) where the deployments are made through FTP transfers to the server.

This cloud migration is designed to comply with the following requirements:

- The application must be containerized;
- The application must to be secure (all data encrypted at rest and in transit)
- The application must to be highly available.
- The application must to support peaks of up to 10 times the average load (scalability).
- The infrastructure must to be reproducible and version-controlled in case the CEO decides to expand the business to other parts of the world (consider infra as code).
- There must be an easy and secure way of developing, with fast feedback  (consider CI/CD practices or at least automation scripts)

### Solution Diagram
![Solution Diagram](images/solution-diagram.png)

### Technologies

* [Github](https://github.com/)
* [Terraform](https://www.terraform.io/)
* [Github actions](https://github.com/features/actions/)
* [Docker](https://www.docker.com/)
* [Docker-compose](https://docs.docker.com/compose/)
* [Amazon Aurora](https://aws.amazon.com/rds/aurora/)
* [Amazon Elastic Container Service](https://aws.amazon.com/ecs/)


<!-- GETTING STARTED -->
## Getting Started

TBC

### Prerequisites

TBC
* tbc
```sh
TBC
```

### Installation

TBC

<!-- USAGE EXAMPLES -->
## Usage

TBC

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/devopsacademyau/2020-jun-project1-group1/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b <branch-name>`)
3. Commit your Changes (`git commit -m 'Add a new contribution'`)
4. Push to the Branch (`git push origin <branch-name>`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the Creative Commons Public Licenses. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

TBC

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/devopsacademyau/2020-jun-project1-group1?style=flat-square
[contributors-url]: https://github.com/devopsacademyau/2020-jun-project1-group1/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/devopsacademyau/2020-jun-project1-group1.svg?style=flat-square
[forks-url]: https://github.com/devopsacademyau/2020-jun-project1-group1/network/members
[stars-shield]: https://img.shields.io/github/stars/devopsacademyau/2020-jun-project1-group1.svg?style=flat-square
[stars-url]: https://github.com/devopsacademyau/2020-jun-project1-group1/stargazers
[issues-shield]: https://img.shields.io/github/issues/devopsacademyau/2020-jun-project1-group1.svg?style=flat-square
[issues-url]: https://github.com/devopsacademyau/2020-jun-project1-group1/issues
[license-shield]: https://img.shields.io/github/license/devopsacademyau/2020-jun-project1-group1.svg?style=flat-square
[license-url]: https://github.com/devopsacademyau/2020-jun-project1-group1/blob/master/LICENSE

