namespace :users do
  task destroy: :environment do
    fail 'Missing info! You need to inform the user ids on USERS_IDS env var (USERS_IDS=1,3,5,6)' if ENV['USERS_IDS'].blank?

    user_ids = ENV['USERS_IDS'].split(',')

    users = User.find(user_ids)

    puts "You're about to delete the following users: "

    users.each do |user|
      puts "=> ##{user.id} #{user.email}"
    end

    puts 'To confirm the deletion of these users, type DELETE (any other text to cancel):'

    input = STDIN.gets.chomp

    if input == 'DELETE'
      users.each(&:destroy)
      puts 'Users destroyed successfully.'
    else
      puts 'Deletion cancelled'
    end
  end
end
