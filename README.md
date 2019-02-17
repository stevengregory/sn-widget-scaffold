# Widget Scaffold

Widget scaffold shell scripts for the ServiceNow Innovation Library.

## Getting Started

1. Clone this repository

    ```bash
    git clone https://github.com/stevengregory/sn-widget-scaffold.git
    cd sn-widget-scaffold
    ```

1. Install the npm packages

    ```bash
    npm install
    ```

1. Generate a scaffold

    ```bash
    yarn build [widget name || widget-name] [options]
    ```

## Options

The following command line options are available:

  ```bash
  -a      Build `angular-template` directory.
  -s      Build `script-include` directory.
  -u      Build `ui-script` directory.
  ```