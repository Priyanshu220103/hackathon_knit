from databases import Database
async def function_client_read_postgres(config_postgres_url,config_postgres_min_connection=5,config_postgres_max_connection=20):
   client_postgres=Database(config_postgres_url,min_size=config_postgres_min_connection,max_size=config_postgres_max_connection)
   await client_postgres.connect()
   print("✅ PostgreSQL connected successfully!")
   return client_postgres

from fastapi import FastAPI
def function_fastapi_app_read(is_debug,lifespan):
   app=FastAPI(debug=is_debug,lifespan=lifespan)
   return app


import os
import importlib.util
from pathlib import Path
import traceback
def function_add_router(app,pattern):
   base_dir = Path(__file__).parent
   def load_module(module_path):
      try:
         rel_path = os.path.relpath(module_path, base_dir)
         module_name = os.path.splitext(rel_path)[0].replace(os.sep, ".")
         if not module_name.strip():
            return
         spec = importlib.util.spec_from_file_location(module_name, module_path)
         if spec and spec.loader:
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            if hasattr(module, pattern):
               app.include_router(module.router)
      except Exception as e:
         print(f"[WARN] Failed to load router module: {module_path}")
         traceback.print_exc()
   def add_root_pattern_files():
      for file in os.listdir(base_dir):
         if file.startswith(pattern) and file.endswith(".py"):
            module_path = base_dir / file
            load_module(module_path)
   def add_pattern_folder_files():
      router_dir = base_dir / pattern
      if router_dir.exists() and router_dir.is_dir():
         for file in os.listdir(router_dir):
            if file.endswith(".py"):
               module_path = router_dir / file
               load_module(module_path)
   add_root_pattern_files()
   add_pattern_folder_files()
   return None


import joblib
import numpy as np
def predict_new_project(original_cost, project_count, cumulative_expenditure, model_path="sector_forecast_model.pkl"):
    """
    Predicts the Latest Revised Cost (Rs Cr) for a new project.
    
    Parameters:
        original_cost (float): Original cost in Rs Cr
        project_count (int): Number of projects in that sector/state
        cumulative_expenditure (float): Cumulative expenditure so far (Rs Cr)
        model_path (str): Path to saved model
    
    Returns:
        float: Predicted Latest Revised Cost (Rs Cr)
    """
    model = joblib.load(model_path)
    X_new = np.array([[original_cost, project_count, cumulative_expenditure]])
    pred_log = model.predict(X_new)
    predicted_cost = np.expm1(pred_log[0])  # reverse log-transform
    return round(predicted_cost, 2)