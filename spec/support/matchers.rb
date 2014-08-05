require 'spec_helper'

RSpec::Matchers.define :be_a_not_allowed_method do
  match do |actual|
    actual.eql? 405
  end
end

RSpec::Matchers.define :be_a_not_found do
  match do |actual|
    actual.eql? 404
  end
end

RSpec::Matchers.define :be_an_unauthorized do
  match do |actual|
    actual.eql? 401
  end
end

RSpec::Matchers.define :be_a_forbidden do
  match do |actual|
    actual.eql? 403
  end
end

RSpec::Matchers.define :be_a_bad_request do
  match do |actual|
    actual.eql? 400
  end
end

RSpec::Matchers.define :be_a_requisition_created do
  match do |actual|
    actual.eql? 201
  end
end

RSpec::Matchers.define :be_a_success_request do
  match do |actual|
    actual.eql? 200
  end
end

RSpec::Matchers.define :be_an_error do |hash_error|
  match do
    parsed_body['error'].eql? hash_error
  end
end

RSpec::Matchers.define :be_a_success_message_with do |success_message|
  match do
    parsed_body['message'].eql? success_message
  end
end

RSpec::Matchers.define :be_an_entity_of do |object, options|
  match do |body|
    options ||= {}
    body.eql? JSON.parse(object.class::Entity.represent(object, options).to_json)
  end
end

RSpec::Matchers.define :include_an_entity_of do |object, options|
  match do |body|
    options ||= {}
    body.include? JSON.parse(object.class::Entity.represent(object, options).to_json)
  end
end
