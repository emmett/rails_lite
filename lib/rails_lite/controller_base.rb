require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
		@req = req
		@res = res
		@params = Params.new(req, route_params)
		@already_built_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
		raise Exception if already_built_response?
		@res["Content-Type"] = type
		@res.body = content
		session.store_session(@res)
		@already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
		@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
		raise Exception if already_built_response?
		@res.status = 302 
		@res.header["location"]= url
		session.store_session(@res)
		@already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
		raise Exception if already_built_response?
		controller_name = self.class.to_s.underscore
		file = File.read "views/#{controller_name}/#{template_name}.html.erb"
		template = ERB.new file
		render_content(template.result(binding) ,"text/html")
		@already_built_response = true
  end

  # method exposing a `Session` object
  def session
		@session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
