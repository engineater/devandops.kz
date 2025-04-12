import platform
from typing import Union

from fastapi import FastAPI
import fastapi_cli.cli

app = FastAPI(docs_url=None,redoc_url=None)


@app.get("/example/hostname")
def read_hostname():
    ### выводим наименование хоста
    return {"host": platform.node()}


@app.get("/example/item_id/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


@app.get("/example/health_check", status_code=200)
async def health_check():
    return {}


if __name__ == '__main__':
    fastapi_cli.cli.run(port=8000, proxy_headers=True, workers=1)

