#!/usr/bin/env python3
"""
식품의약품안전처 가공식품 영양성분 DB를 JSON으로 변환하는 스크립트

Input: docs/식품의약품안전처_가공식품 품목별 영양성분 DB_20221231.xlsx
Output: assets/data/food_database.json
"""

import json
import re
import pandas as pd
from pathlib import Path


def parse_serving_size(value):
    """
    영양성분기준용량에서 숫자만 추출
    예: "100g" -> 100.0, "100ml" -> 100.0
    """
    if pd.isna(value) or value == "-":
        return 100.0

    # 문자열로 변환 후 숫자 추출
    str_value = str(value)
    match = re.search(r'(\d+(?:\.\d+)?)', str_value)
    if match:
        return float(match.group(1))
    return 100.0


def parse_numeric_value(value, default=0.0, nullable=False):
    """
    숫자 값 파싱
    - "-" 또는 빈값은 null(nullable) 또는 default로 처리
    """
    if pd.isna(value) or value == "-" or value == "":
        return None if nullable else default

    try:
        return float(value)
    except (ValueError, TypeError):
        return None if nullable else default


def convert_excel_to_json():
    # 경로 설정
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    input_path = project_root / "docs" / "식품의약품안전처_가공식품 품목별 영양성분 DB_20221231.xlsx"
    output_path = project_root / "assets" / "data" / "food_database.json"

    # 출력 디렉토리 생성
    output_path.parent.mkdir(parents=True, exist_ok=True)

    print(f"Reading Excel file: {input_path}")

    # Excel 파일 읽기
    df = pd.read_excel(input_path)

    print(f"Total rows in Excel: {len(df)}")

    # 컬럼 매핑
    column_mapping = {
        "대표식품명": "name",
        "영양성분기준용량": "servingSize",
        "에너지\n(kcal)": "calories",
        "탄수화물\n(g)": "carbs",
        "단백질\n(g)": "protein",
        "지방\n(g)": "fat",
        "당류\n(g)": "sugar",
        "나트륨\n(mg)": "sodium"
    }

    # 필요한 컬럼만 선택
    df_filtered = df[list(column_mapping.keys())].copy()

    # 빈 이름 제거
    df_filtered = df_filtered[df_filtered["대표식품명"].notna()]
    df_filtered = df_filtered[df_filtered["대표식품명"] != ""]
    df_filtered = df_filtered[df_filtered["대표식품명"] != "-"]

    print(f"Rows after removing empty names: {len(df_filtered)}")

    # 중복 제거 (같은 이름, 첫번째 유지)
    df_filtered = df_filtered.drop_duplicates(subset=["대표식품명"], keep="first")

    print(f"Rows after removing duplicates: {len(df_filtered)}")

    # 데이터 변환
    foods = []
    for idx, row in df_filtered.iterrows():
        food_item = {
            "id": str(len(foods)),
            "name": str(row["대표식품명"]).strip(),
            "servingSize": parse_serving_size(row["영양성분기준용량"]),
            "calories": parse_numeric_value(row["에너지\n(kcal)"], default=0.0),
            "carbs": parse_numeric_value(row["탄수화물\n(g)"], default=0.0),
            "protein": parse_numeric_value(row["단백질\n(g)"], default=0.0),
            "fat": parse_numeric_value(row["지방\n(g)"], default=0.0),
            "sugar": parse_numeric_value(row["당류\n(g)"], nullable=True),
            "sodium": parse_numeric_value(row["나트륨\n(mg)"], nullable=True)
        }
        foods.append(food_item)

    # JSON 구조 생성
    output_data = {
        "foods": foods,
        "version": "20221231",
        "totalCount": len(foods)
    }

    # JSON 파일 저장
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)

    print(f"JSON file created: {output_path}")
    print(f"Total food items: {len(foods)}")

    # 첫 번째 항목 출력 (검증용)
    print("\nFirst food item:")
    print(json.dumps(foods[0], ensure_ascii=False, indent=2))

    return output_path


if __name__ == "__main__":
    convert_excel_to_json()
