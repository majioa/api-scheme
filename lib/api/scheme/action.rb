require "api/scheme/version"

module Api::Scheme::Action
   SCHEME = {
      fetch_model_instances: {
         before: :index
      },
      fetch_model_instance: {
         before: %i(show update destroy)
      },
      init_model_instance: {
         before: :create
      }
   }

   def index
      render_default_success models_key => model_instances
   end

   def show
      render_default_success model_key => model_instance
   end

   def create
      model_instance.save!

      render_default_success({ model_key => model_instance }, status: :created)
   end
   
   def update
      model_instance.update!(permitted_params)

      render_default_success({ model_key => model_instance }, status: :ok)
   end

   def destroy
      model_instance.destroy!

      render_default_success({ model_key => model_instance }, status: :ok)
   end

   def fetch_model_instances
      self.model_instances = model.all
   end

   def fetch_model_instance
      self.model_instance = model.find(params[:id])
   end

   def init_model_instance
      self.model_instance = model.new(permitted_params)
   end

   class << self
      def define_for klass, name
         method = self.instance_method(name)
         klass.send(:define_method, name, method)
      end
   end
end
