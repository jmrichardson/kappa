from celery import Celery


app = Celery('tasks', broker='amqp://user:bitnami@localhost//')

@app.task
def add(x, y):
    return x + y
