class SomemodelSerializer < ActiveModel::Serializer
  attributes :id

  def default_serializer_options
    {:root => false}
  end


end

