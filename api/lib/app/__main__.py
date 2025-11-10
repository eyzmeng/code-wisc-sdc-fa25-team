if __name__ == '__main__':
    from . import App
    import argparse
    import textwrap

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument('-d', action='store_true', help='enable debug')
    parser.add_argument('-b', default='127.0.0.1', help='bind address', metavar='BIND')
    parser.add_argument('--cors', action='store_true', help=textwrap.dedent(
        "allow Cross-Origina Requests (requires flask-cors, "
        "which is installed with 'poetry install --with devel')"
    ))
    parser.add_argument('port', default='8000', help='listening port', nargs='?')
    args = parser.parse_args()
    app = App().to_wsgi_app()
    if args.cors:
        from flask_cors import CORS
        CORS(app)
    app.run(debug=args.d, host=args.b, port=args.port)
