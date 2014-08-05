module IntegrationHelper
  def parsed_body
    JSON.parse(response.body)
  end
end
