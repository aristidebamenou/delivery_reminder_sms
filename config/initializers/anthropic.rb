# Un seul client pour toute l'app : il est threadsafe et gère son pool de connexions.
# Sans argument, il lit ENV["ANTHROPIC_API_KEY"].
ANTHROPIC_CLIENT = Anthropic::Client.new
