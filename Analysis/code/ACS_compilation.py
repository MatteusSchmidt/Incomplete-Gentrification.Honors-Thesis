import pandas as pd

path = "/Users/schmidt/Desktop/Research"
data_path = path + "/raw/ACS"
output_path = path + "/Analysis/data/processed"

DP03_alias = pd.read_csv(data_path + "/DP03_alias.csv")
DP03_names = DP03_alias["year"].tolist()
DP04_alias = pd.read_csv(data_path + "/DP04_alias.csv")
DP04_names = DP04_alias["year"].tolist()
DP05_alias = pd.read_csv(data_path + "/DP05_alias.csv")
DP05_names = DP05_alias["year"].tolist()
S1501_alias = pd.read_csv(data_path + "/S1501_alias.csv")
S1501_names = S1501_alias["year"].tolist()
S2503_alias = pd.read_csv(data_path + "/S2503_alias.csv")
S2503_names = S2503_alias["year"].tolist()

print(DP03_alias.head())

def get_key_values(data, desired_attributes, column_names):
    desired_attributes.append("NAME")
    data = data[desired_attributes]
    rename_dict = {desired_attributes[j]: column_names[j] for j in range(len(column_names))}
    rename_dict["NAME"] = "zip"
    data = data.rename(columns=rename_dict)
    data["zip"] = data["zip"].astype(str).str[-5:].astype(int)
    return data

# DP03 Processing
for i in range(2015, 2024):
    temp_path = data_path + "/DP03-2015-2023"
    df = pd.read_csv(temp_path + f"/ACSDP5Y{i}.DP03-Data.csv")
    df = df.iloc[1:].reset_index(drop=True)
    attributes = DP03_alias[str(i)].tolist()
    df = get_key_values(df, attributes, DP03_names)
    df.to_csv(output_path + f"/DP03_{i}.csv", index=False)

# DP04 Processing
for i in range(2015, 2024):
    temp_path = data_path + "/DP04-2015-2023"
    df = pd.read_csv(temp_path + f"/ACSDP5Y{i}.DP04-Data.csv")
    df = df.iloc[1:].reset_index(drop=True)
    attributes = DP04_alias[str(i)].tolist()
    df = get_key_values(df, attributes, DP04_names)
    df.to_csv(output_path + f"/DP04_{i}.csv", index=False)

# DP05 Processing
for i in range(2015, 2024):
    temp_path = data_path + "/DP05-2015-2023"
    df = pd.read_csv(temp_path + f"/ACSDP5Y{i}.DP05-Data.csv")
    df = df.iloc[1:].reset_index(drop=True)
    attributes = DP05_alias[str(i)].tolist()
    df = get_key_values(df, attributes, DP05_names)
    df.to_csv(output_path + f"/DP05_{i}.csv", index=False)

# S1501 Processing
for i in range(2015, 2024):
    temp_path = data_path + "/S1501-2015-2023"
    df = pd.read_csv(temp_path + f"/ACSST5Y{i}.S1501-Data.csv")
    df = df.iloc[1:].reset_index(drop=True)
    attributes = S1501_alias[str(i)].tolist()
    df = get_key_values(df, attributes, S1501_names)
    df.to_csv(output_path + f"/S1501_{i}.csv", index=False)

# S2305 Processing
for i in range(2015, 2024):
    temp_path = data_path + "/S2503-2015-2023"
    df = pd.read_csv(temp_path + f"/ACSST5Y{i}.S2503-Data.csv")
    df = df.iloc[1:].reset_index(drop=True)
    attributes = S2503_alias[str(i)].tolist()
    df = get_key_values(df, attributes, S2503_names)
    df.to_csv(output_path + f"/S2503_{i}.csv", index=False)

# combining data
for i in range(2015, 2024):
    s_df = pd.read_csv(output_path + f"/S1501_{i}.csv")
    pd05_df = pd.read_csv(output_path + f"/DP05_{i}.csv")
    pd03_df = pd.read_csv(output_path + f"/DP03_{i}.csv")
    pd04_df = pd.read_csv(output_path + f"/DP04_{i}.csv")
    s25_df = pd.read_csv(output_path + f"/S2503_{i}.csv")
    df = pd.merge(s_df, pd05_df, how="left", on="zip")
    df = pd.merge(df, pd03_df, how="left", on="zip")
    df = pd.merge(df, pd04_df, how="left", on="zip")
    df = pd.merge(df, s25_df, how="left", on="zip")
    df.to_csv(output_path + f"/ACS_{i}.csv", index=False)
