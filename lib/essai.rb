require './jacman/core.rb'
JacintheManagement::Core::Cli.user.run(['en'])

JacintheManagement::Core::Notification.notify_all
