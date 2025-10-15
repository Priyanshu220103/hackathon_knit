import pandas as pd
from sqlalchemy import create_engine

# ========================
# 🔧 CONFIGURATION SECTION
# ========================

# ✅ Replace this with your actual PostgreSQL DB URL
# Format: postgresql+psycopg2://username:password@hostname:port/database_name
DB_URL = "postgresql://neondb_owner:npg_MizK1lohV0eX@ep-frosty-cherry-a1g2j3ow-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require"

# ✅ Path to your uploaded CSV file
FILE_PATH = "csvs/clustered_projects.csv"

# ✅ Target table name
TABLE_NAME = "clustered_projects"

# Columns to exclude when inserting data
EXCLUDE_COLUMNS = ['SNo']

# ========================
# 🚀 MAIN SCRIPT
# ========================

COLUMN_MAPPING = {
    "SNo": "id",
    "State": "states",
    "Expenditure": "expenditure",
    "Progress": "progress",
    "Project_Name": "project_name",
    "Agency": "agency",
    "Dateof_Approval": "date_of_approval",
    "Start_Date": "start_date",
    "Org_DoC": "original_date_of_completion",
    "Rev_DoC": "revised_date_of_completion",
    "Org_Cost": "original_cost",
    "Rev_Cost": "revised_cost"
}


# def insert_csv_to_postgres(csv_path, db_url, table_name):
#     # Read CSV (skip header row if it shouldn't be inserted)
#     df = pd.read_csv(csv_path)

#     # Drop any empty rows just in case
#     df = df.dropna(how="all")

#     # Rename columns as per mapping
#     df = df.rename(columns=COLUMN_MAPPING)

#     # Keep only columns that exist in mapping
#     df = df[list(COLUMN_MAPPING.values())]

#     print("✅ Columns after renaming:", list(df.columns))
#     print(f"📊 Rows ready for insertion: {len(df)}")

#     # Connect to PostgreSQL
#     engine = create_engine(db_url)

#     # Insert into PostgreSQL
#     df.to_sql(table_name, engine, if_exists="append", index=False)
#     print(f"🎉 Successfully inserted {len(df)} rows into '{table_name}' table.")


# if __name__ == "__main__":
#     try:
#         insert_csv_to_postgres(FILE_PATH, DB_URL, TABLE_NAME)
#     except Exception as e:
#         print("❌ Error inserting data:", e)



def insert_csv_to_postgres(csv_path, db_url, table_name):
    try:
        # Read CSV
        print("📋 Reading CSV file...")
        df = pd.read_csv(csv_path)
        print(f"📋 Columns in CSV: {list(df.columns)}")
        
        # Drop the Sl.No column if it exists
        for col in EXCLUDE_COLUMNS:
            if col in df.columns:
                df = df.drop(columns=[col])
        
        # Convert all column names to lowercase
        df.columns = df.columns.str.lower()
        
        # Drop any empty rows just in case
        df = df.dropna(how="all")
        
        print(f"📊 Total rows found: {len(df)}")
        
        # Create SQLAlchemy engine
        engine = create_engine(db_url)
        
        # Insert data into PostgreSQL
        df.to_sql(
            name=table_name,
            con=engine,
            if_exists='append',
            index=False
        )
        
        print("✅ Data inserted successfully!")
        
    except Exception as e:
        print(f"❌ Error inserting data: {e}")

if __name__ == "__main__":
    try:
        insert_csv_to_postgres(FILE_PATH, DB_URL, TABLE_NAME)
    except Exception as e:
        print("❌ Error inserting data:", e)