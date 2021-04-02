using HTTP
using JSON


API_URL = "http://dataservices.imf.org/REST/SDMX_JSON.svc"
api_method = "/DataStructure/"
dataset_id = "IFS"

query = string(API_URL, api_method, dataset_id)

response = HTTP.get(query)
if response.status != 200
    error("Invalid request")
end
response_body = String(response.body)
response_json = JSON.parse(response_body)
