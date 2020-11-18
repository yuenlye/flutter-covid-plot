import csv

countries = ["Australia", "Malaysia", "New Zealand"]
country_data = {}

# Initialize previous total cases for each countries
# This is to ensure data integrity in case there are missing entry
country_total_cases = {country: '0' for country in countries}

with open('owid-covid-data.csv') as csvfile:
    rows = csv.reader(csvfile)

    for row in rows:
        country = row[2]
        if (country in countries):
            total_cases = str(
                int(float(row[4]))) if row[4] != '' else country_total_cases[country]
            country_total_cases[country] = total_cases

            if (country not in country_data):
                country_data[country] = []

            country_data[country].append("\t".join([row[3], total_cases]))


for country in country_data:
    with open('data/{country}.tsv'.format(country=country.replace(' ', '_')), 'w+') as country_output:
        country_output.write("\n".join(country_data[country]))
