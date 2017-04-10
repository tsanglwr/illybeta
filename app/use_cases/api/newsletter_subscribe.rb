class Api::NewsletterSubscribe < Mutations::Command

  required do
    string :email
    string :list_id
  end
 
  def execute
  	gb = Gibbon::API.new
	gb.lists.subscribe({:id => inputs[:list_id], :email => {:email => inputs[:email]},  :double_optin => false})
  end
end


