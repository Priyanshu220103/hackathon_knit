from imports import *
from function import *

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI(title="Analysis Data API")

# Database configuration
config_postgres_url = os.getenv("DATABASE_URL")
config_postgres_min_connection = os.getenv("POSTGRES_MIN_CONNECTION", 5)
config_postgres_max_connection = os.getenv("POSTGRES_MAX_CONNECTION", 20)

#lifespan
from fastapi import FastAPI
from contextlib import asynccontextmanager
import traceback
@asynccontextmanager
async def lifespan(app:FastAPI):
   try:
    client_postgres=await function_client_read_postgres(config_postgres_url,config_postgres_min_connection,config_postgres_max_connection) if config_postgres_url else None
    app.state.client_postgres = client_postgres
    yield
    if client_postgres:await client_postgres.disconnect()
   except Exception as e:
      print(str(e))
      print(traceback.format_exc())

#app
app=function_fastapi_app_read(True,lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

function_add_router(app,"router")

@app.get("/")
def root():
    return {"message": "✅ FastAPI connected to PostgreSQL successfully!"}
