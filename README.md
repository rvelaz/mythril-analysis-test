This is a sample project that shows how to run Mythril analysis from CircleCi. The analysis
is run using a docker image called [rvelaz/mythril-ci](https://hub.docker.com/r/rvelaz/mythril-ci/)

## Contents
* .circleci: contains a sample of CircleCi configuration
* ci-script: contains a script that allows to run multiple Mythril analsysis on muyltiple solidity files
* src: [Solidity examples](https://github.com/b-mueller/mythril/tree/master/solidity_examples) that fail Mythril analysis
* src/pass: Solidity file that passes Mythril analysis


## Script to execute multiple tests
*ci-script/execute_tests.sh* has different options but basically it allows to run one or more tests, pass any options that myth supports and generate a report file.

The following command will execute Mythril analysis for all files in the *src* directory, display the output in JSON format and save the analysis results in the file *analysis.json*:

```
execute_tests.sh -o '-x -o json' -s src/ -r analysis.json
```



## Running myth directly
If you want to run *myth* directly in your pipeline:
```yaml
version: 2
jobs:
  build:
    docker:
      - image: rvelaz/mythril-ci:0.2.0
    steps:
      - checkout
      - run:
          name: Execute analysis
          command: |
            bash myth -x file.sol
```

Even the analysis fails, that will not mark the build as failed. You can use the script *ci-script/execute_tests.sh* to run one or multiple tests. If there are failures, it will mark the build as failed.

## Running all the tests and create a JUnit compatible report
I've created a tool [rvelaz/mythril-junit-report](https://github.com/rvelaz/mythril-junit-report) that takes the JSON output produced by Mythril and transforms it to JUnit compatible XML that can be interpreted by CircleCI. Here's an example of the output produced by CircleCI:

![Failed Mythril analysis](https://github.com/rvelaz/mythril-analysis-test/blob/master/static/screenshot.png)

The steps are:
* Pull the code
* Run Mythril analysis and produce a report file
* Install go,  [mythril-junit-report](https://github.com/rvelaz/mythril-junit-report) and create the JUnit compatible report

```yaml
version: 2
jobs:
  build:
    docker:
      - image: rvelaz/mythril-ci:0.2.0
    steps:
      - checkout
      - run:
          name: Execute analysis
          command: |
            bash ./ci-script/execute_tests.sh -o '-x -o json' -s src -r results.json
      - run:
          name: Install go
          when: always
          command: |
            apt-get install -y golang-1.9-go
      - run:
          name: Export to junit
          when: always
          command: |
            export GOROOT=/usr/lib/go-1.9
            export PATH=$GOROOT/bin:$PATH
            echo $PATH
            go get -u github.com/rvelaz/mythril-junit-report
            export PATH=/root/go/bin:$PATH
            mkdir ~/mythril-results
            cat results.json | mythril-junit-report > ~/mythril-results/report.xml

      - store_test_results:
          path: ~/mythril-results
```
