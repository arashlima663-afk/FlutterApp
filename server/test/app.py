import fastapi as _fastapi
app = _fastapi.FastAPI()


@app.post("/")
async def create_user():


    return 'ok'

@app.get("/")
async def create_user():


    return 'ok'

