from imports import *
from function import *

@router.get("/lol")
async def read_root(request: Request):
    return {"message": "Hello, World!"}

from fastapi import Form

@router.post("/analysis-data")
async def read_all_items(request: Request, table_name: str = Form(), page: int = Form(1), page_size: int = Form(20)):
    try:
        # Calculate offset for pagination
        offset = (page - 1) * page_size

        # Get total count
        count_query = f"SELECT COUNT(*) as total FROM {table_name}"
        db = request.app.state.client_postgres
        count_result = await db.fetch_one(count_query)
        total_records = count_result['total']

        # Get paginated data
        query = f"SELECT * FROM {table_name} LIMIT {page_size} OFFSET {offset}"
        result = await db.fetch_all(query)

        # Calculate pagination metadata
        total_pages = (total_records + page_size - 1) // page_size
        has_next = page < total_pages
        has_prev = page > 1

        return {
            "data": [dict(row) for row in result],
            "pagination": {
                "current_page": page,
                "page_size": page_size,
                "total_records": total_records,
                "total_pages": total_pages,
                "has_next": has_next,
                "has_prev": has_prev
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.post("/prediction-for-cost")
async def predict_cost(request: Request, original_cost: float = Form(), project_count: int = Form(), cumulative_expenditure: float = Form()):
    try:
        print("check point 1")
        predicted_cost = predict_new_project(original_cost, project_count, cumulative_expenditure)
        return {"predicted_cost": predicted_cost}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))