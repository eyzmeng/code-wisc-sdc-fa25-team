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
