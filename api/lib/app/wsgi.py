from . import App

__all__ = ['app']

app = App().to_wsgi_app()
