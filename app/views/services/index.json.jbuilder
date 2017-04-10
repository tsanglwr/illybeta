json.array!(@apis) do |api|
  json.extract! api, :id, :name, :identifier
  json.url api_url(api, format: :json)
end
