class Api::GetEmailInUse < Mutations::Command

  required do
    string :email
  end

  def execute

    user = User.find_by_email(inputs[:email])
    user != nil

  end
end


