"""
An example unittest from README.md.  This file can be run
as an individual script or loaded from 'python -m unittest'
discovery.
"""

import unittest

from app import App


class TestExample(unittest.TestCase):
    def test_greet(self):
        app = App()
        self.assertEqual(app.greet(), "Hello SDC Team 17!")


# When being run as a script, load ourselves
if __name__ == '__main__':
    unittest.main()
