class GetPosts < ActiveInteraction::Base

  def execute
    [
        "http://www.placehold.it/200x200",
        "http://www.placehold.it/230x200"
    ]
  end
end
