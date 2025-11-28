# api - Backend code

## Development

You should have read HACKING already.

Start development server using

```
poetry run python -m app
```

This listens on port 8000 by default.  Access <http://localhost:8000/>
to see if it worked.
(The host name is very significant.  **Do not use 127.0.0.1**.)


## Structure

Everything lives in `lib` or `tests`.

The `__init__.py` file defines package-wide functions import objects
from it using `from . import <name>`.  The other files define modules
and can be imported from using `from .<module> import <name>` (given
that `<module>` is the name of the file, `<module>.py`.)

You may ask why I structure `__init__.py` like this.  Well the
thing is: HTTP is expensive for testing.  WSGI is less so, but
it's still ultimately a layer on top.  So what I think we do is
we separate the routing (presentation) layer from the implementation
(business logic) layer, so that when the latter becomes nontrivial,
it is possible to just test against that instead of having to spin
up a WSGI/HTTP server.

Here's what I mean if you look at the example `/api/v1/greet`
interface:

```python
    def to_flask_app(self):
        app = flask.Flask(self.name)

        @app.route('/api/v1/greet')
        def index():
            payload = self.jsonify({'message': self.greet(), 'ok': True})
            return flask.Response(payload, content_type='application/json')
```

You'll see that the real logic is implemented in `app.greet()`:


```python
    def greet(self):
        return 'Hello {0[name]}!'.format(self.ctx)
```

so it becomes possible to test it in isolation, with say, a unittest case:

```python
import unittest

from app import App

class TestExample(unittest.TestCase):
    def test_greet(self):
        app = App()
        self.assertEqual(app.greet(), "Hello SDC Team 17!")

if __name__ == '__main__':
    unittest.main()
```

To run this you should install this project editable mode in your
virtual environment first.  That is, run "`pip install -e .`".

Then:

```
$ python -m unittest discover tests
.
----------------------------------------------------------------------
Ran 1 test in 0.024s

OK

$ python tests/test_example.py
.
----------------------------------------------------------------------
Ran 1 test in 0.024s

OK
```
