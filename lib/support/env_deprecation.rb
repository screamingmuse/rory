DEPRECATION_LIMIT = 100_000_000_000
cloned_env = ENV.clone
ENV.instance_variable_set('@rory_stage_call_count', 0)

ENV.define_singleton_method(:rory_stage_call_count) do
  self.instance_variable_get('@rory_stage_call_count')
end

ENV.define_singleton_method(:'[]') do |arg|
  rory_stage_call_count = ENV.instance_variable_get('@rory_stage_call_count') + 1

  if rory_stage_call_count == DEPRECATION_LIMIT
    abort_msg = %Q!
    STOP CALLING 'RORY_STAGE' USE 'RORY_ENV'
    I WARNED YOU REPEATLY, AND YOU DIDN'T LISTEN
    SO NOW I AM FORCED TO DISPLAY THIS VERY NASTY MESSAGE 
    THIS HURTS ME AS MUCH AS IT HURTS YOU
    !
    abort(abort_msg)
  end

  if arg == "RORY_STAGE"
    ENV.instance_variable_set('@rory_stage_call_count', rory_stage_call_count)
    warn %Q!
    DEPRECATION: use 'RORY_ENV' instead of 'RORY_STAGE'
    You have been warned #{ENV.rory_stage_call_count} times
    If you use 'RORY_STAGE' #{DEPRECATION_LIMIT - ENV.rory_stage_call_count} more times 
    I swear to \#\{@higher_power} I raise the biggest error you have ever seen
    !
    return cloned_env.send(:'[]', 'RORY_STAGE')
  else
    cloned_env.send(:'[]', arg)
  end
end
