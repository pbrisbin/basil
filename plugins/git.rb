GIT_COMMANDS ||= Hash.new {
  # unknown commands will execute this
  "echo 'usage: git [ #{GIT_COMMANDS.keys.join(' | ')}' ]"
}

GIT_COMMANDS['pull'] = 'git pull origin master'
GIT_COMMANDS['show'] = 'git log HEAD --oneline | head -n 1'

Basil.respond_to(/^git (.*)$/) do
  # Note: assumes if we're in any git repo, we're in /our/ git repo.
  if system('git status &>/dev/null')
    @msg.reply `#{GIT_COMMANDS[@match_data[1]]}`
  else
    @msg.reply "Sorry, I'm not running in my repo :("
  end
end
