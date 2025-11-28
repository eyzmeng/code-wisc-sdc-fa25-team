import datetime
import json
import sqlalchemy

from pathlib import Path
from werkzeug.exceptions import HTTPException

__all__ = ['App']

# Teach json.encoder.JSONEncoder how to encode datetime
# instances, as translated by SQLAlchemy from the SQLite
# DATETIME field.  See this:
# https://stackoverflow.com/a/43663981/19411800
class JSONEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, (
            datetime.datetime,
            datetime.date,
            datetime.time,
        )):
            return o.isoformat()
        return super().default(o)


class App(object):
    def __init__(self, name=__name__, /):
        self.name = name
        self.ctx = {
            'name': 'SDC Team 17',
            'engine': sqlalchemy.create_engine(self.get_database()),
        }
        # autoload_with documented here:
        # https://docs.sqlalchemy.org/en/20/core/reflection.html
        self.schema = {
            'clubs': sqlalchemy.Table(
                'clubs',
                sqlalchemy.MetaData(),
                autoload_with=self.ctx['engine'],
            ),
        }

    def jsonify(self, payload):
        return json.dumps(payload, cls=JSONEncoder)

    def get_database(self):
        return f'sqlite:///{Path(__file__).parent / "db.sqlite3"}'

    def greet(self):
        return 'Hello {0[name]}!'.format(self.ctx)

    def search(self, params):
        # A very bad search function -- it just finds whatever matches
        # the query (the text inside the giant search bar) verbatim.
        #
        # Someone teach this guy to be smarter than that....
        #
        #    - Fuzzy club name match
        #    - Tags
        #    - Full text search
        #
        # etc, etc.  Lots of ways to improve....
        table = self.schema['clubs']
        with self.ctx['engine'].connect() as conn:
            statement = sqlalchemy.select(table).where(table.c.name == params['query'])
            row = conn.execute(statement).fetchone()

        # The Row._mapping attribute is a Python dict-like object
        # https://docs.sqlalchemy.org/en/20/core/connections.html#sqlalchemy.engine.Row._mapping
        # From: https://stackoverflow.com/a/1958228/19411800
        if row:
            payload = [dict(row._mapping)]
        else:
            payload = []

        return payload

    def to_flask_app(self):
        import flask
        app = flask.Flask(self.name)

        @app.route('/api/v1/greet')
        def index():
            payload = self.jsonify({'message': self.greet(), 'ok': True})
            return flask.Response(payload, content_type='application/json')

        @app.errorhandler(HTTPException)
        def handle_http_exception(e):
            response = e.get_response()
            response.data = self.jsonify({
                'ok': False,
                "error": e.name,
                "description": e.description,
                "code": e.code,
            })
            response.content_type = "application/json"
            return response

        @app.route('/api/v1/search', methods=['POST'])
        def search():
            if not flask.request.is_json:
                flask.abort(415, description='Need application/json')
            payload = self.jsonify({'results': self.search(flask.request.json), 'ok': True})
            return flask.Response(payload, content_type='application/json')

        return app

    def to_wsgi_app(self):
        return self.to_flask_app()
