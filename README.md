# Python Nosetests

Run python nosetests from within the [Atom](https://atom.io/) editor.

![Screenshot](https://github.com/thschenk/atom-nosetests/raw/master/screenshot.png)

**Note:** This package is in early stage of development.
Although the basics are working, the usability needs to be improved further.


## Installation

This package depends on the [nose](https://nose.readthedocs.org/en/latest/) and
[nosetests-json-extended](https://github.com/thschenk/nosetests-json-extended) python plugins.
They can be installed with:

    sudo pip install nose nosetests-json-extended


## Usage

When running nosetests for the first time on a project,
go to the project root and run the tests from the command line:

    (python2) nosetests --with-json-extended
    (python3) python3 -m nose --with-json-extended

This will generate a file `nosetests.json` which contains,
besides the test results, also the required information to re-run the tests.

In the Atom editor, open a file that belongs to the project and go to:

    Menu -> Packages -> Python Nosetests -> Run   (Or press F5)

The *Python Nosetests* package will now locate the `nosetests.json` file, run the tests again and show the results.

When trying this package, this [python-testproject](https://github.com/thschenk/python-testproject)
can be used to generate some succeeding, failing and erroneous test cases.


## Roadmap

 * Resizable separation between test cases and traceback.
 * Hide traceback items from python unittest module.
 * Create specs.
 * Visual feedback when test results are updated.
