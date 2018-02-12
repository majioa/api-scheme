require "api/scheme/version"
require "api/scheme/action"

module Api::Scheme
   def self.included klass
      # NOTE put default render handlers to the module to use from as if is the ancestor
      self.instance_variable_set(:@success_proc, :default_success_proc)
      self.instance_variable_set(:@error_proc, :default_error_proc)

      klass.class_eval %Q"
         class << self
            def error_map map
               @error_map ||= map
            end

            def model_error_map map
               @model_error_map ||= map
            end

            def param_map map
               @param_map ||= map
            end

            def render_success_with method = nil, &prc
               @success_proc ||= method || prc
            end

            def render_error_with method = nil, &prc
               @error_proc ||= method || prc
            end

            def render_error_code options = {}
               @error_proces = (@error_proces || {}).merge(options)
            end

            def use_model name
               @model_name = name
            end

            def use_actions *list
               list.each do |action|
                  Api::Scheme::Action.define_for(self, action)
               end

               Api::Scheme::Action::SCHEME.each do |method_name, cases|
                  before = [ cases[:before] ].flatten.compact & list

                  if before.present?
                     Api::Scheme::Action.define_for(self, method_name)
                     self.before_action(method_name, only: before)
                  end
               end
            end
         end
      "

      klass.rescue_from StandardError, with: :render_default_error
   end

   def _getter var
      self.class.ancestors.reduce(nil) { |value, klass| value || klass.instance_variable_get(var) }
   end

   def error_map
      error_map = _getter(:@error_map)

      error_map ||= map
      return error_map if _getter(:@error_map_parsed)

      error_map = parse_error_map
      self.class.instance_variable_set(:@error_map_parsed, true)
      self.class.instance_variable_set(:@error_map, error_map)
   end

   def parse_error_map
      error_map = _getter(:@error_map)
      error_map.map do |(errors, code)|
         list = errors.map do |e|
            begin
               e.constantize
            rescue NameError
               begin
                  "#{self.class}::#{e}".constantize
               rescue NameError
                  begin
                     send(:class_eval, e.camelize)
                  rescue NameError
                     raise InvalidErrorTypeError, e
                  end
               end
            end
         end

         [ list, code ]
      end.to_h
   end

   def code_parse code, e
      json = { message: e.message, type: e.class }

      case code
      when Range
         logger.error "#{e.class}: #{e.message}"

         [ code.first, json.merge(error_code: code.last) ]
      when NilClass
         logger.error "#{e.class}: #{e.message}\n\t#{e.backtrace[0...50].join("\n\t")}"

         [ 500, json ]
      else
         logger.error "#{e.class}: #{e.message}"

         [ code, json ]
      end
   end

   def get_code_of_model_error_map e
      error_text = e.record.errors.messages.reduce(nil) {|s, (_, v)| s || v.join }

      _getter(:@model_error_map).to_a.reverse.reduce(nil) do |code, (re, new_code)|
         re =~ error_text && new_code || code
      end
   end

   def get_code_of_error_map e
      error_map.find do |errors, codes|
         errors.any? { |error| e.kind_of?(error) }
      end.try(:last)
   end

   def get_pure_code code
      if code.is_a?(Range)
         code.begin
      else
         code
      end
   end

   def get_sub_code code
      if code.is_a?(Range)
         code.end
      end
   end

   def get_code_text code
      path = code.is_a?(Range) && "#{code.begin}.#{code.end}" || code.to_s

      I18n.t("action_controller.#{controller_path}.errors.#{path}")
   end

   def render_default_success data, options = {}
      success_proc = _getter(:@success_proc)

      prc = success_proc.kind_of?(Proc) && success_proc || self.method(success_proc.to_s.to_sym)

      prc[data, options]
   end

   def render_default_error e
      code =
      if e.to_s.split('::').last == 'Validations'
         get_code_of_model_error_map(e)
      else
         get_code_of_error_map(e)
      end

      error_proces = _getter(:@error_proces)
      error_proc = error_proces[code] || error_proc = _getter(:@error_proc)

      prc = error_proc.kind_of?(Proc) && error_proc || self.method(error_proc.to_s.to_sym)
      args = [get_code_text(code), get_sub_code(code), get_pure_code(code), code, e ]

      prc[*args[0...prc.arity.abs]]
   end

   def default_success_proc data
      render data: data, status: 200
   end

   def default_error_proc _, _, _, code, e
      status, json = code_parse(code, e)

      render data: json, status: status
   end

   def model
      @model ||= _getter(:@model_name).constantize
   end

   def model_key
      model.name.tableize.singularize
   end

   def models_key
      model.name.tableize
   end

   def model_instance
      self.instance_variable_get(:"@#{model_key}")
   end

   def model_instances
      self.instance_variable_get(:"@#{models_key}")
   end

   def model_instance= value
      self.instance_variable_set(:"@#{model_key}", value)
   end

   def model_instances= value
      self.instance_variable_set(:"@#{models_key}", value)
   end

   def permitted_params_require key, map
      params.require(key).permit(*map)
   end

   def permitted_params_permit keys
      default = {}

      keys.reduce(default) do |h, key|
         value = /(?<name>.*)\?$/ =~ key ? params[name] : params.require(key)
         value.nil? && h || h.merge( (name || key).to_sym => value )
      end
   end

   def permitted_params
      param_map = _getter(:@param_map)

      if param_map.is_a?(Hash)
         permitted_params_require(param_map.keys.first, param_map.values.first)
      else
         permitted_params_permit([ param_map ].flatten)
      end
   end

   def validate_access_token
      raise InvalidUserError if not current_user
   end
end
