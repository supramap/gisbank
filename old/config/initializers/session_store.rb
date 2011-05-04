# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gisaid_session',
  :secret      => 'fc273b150f9705052bfa77d75c94deb8d5913cb9fdefe5d3f4b49de016631500beaf8ca2cf9a1a190ea1ddc9bac7fd57729e0913336f028ba8d7a82d36de7803'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
