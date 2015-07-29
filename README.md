# Python Nosetests

Run python [nosetests](https://nose.readthedocs.org/en/latest/) from within the [Atom](https://atom.io/) editor.

![Screenshot](https://github.com/thschenk/atom-nosetests/raw/master/screenshot.png)


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

## Django nose tests

You can run django nose tests also with this plugin. Install `django_nose`:

    sudo pip install django_nose

Follow installation instructions at [django_nose](https://django-nose.readthedocs.org/en/latest/)

Then put configuration to your `settings.py` file:

    BASE_DIR = os.path.dirname(os.path.dirname(__file__)
    NOSE_ARGS = ("--with-json-extended", "--config={}/nose.cfg".format(BASE_DIR))
    TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'

By specifying `nose.cfg` you can specify exactly which tests you want to perform.

Example nose.cfg:

    [nosetests]
    tests=app.tests.test_models

After that enable custom command in package settings and leave the default or provide your own.


## Roadmap
 * Hide traceback items from python unittest module.
 * Provide a way to run nosetests if no `nosetests.json` is found
 * Create specs.
