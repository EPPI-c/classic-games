local statemachine = {}

function statemachine:changeState(state, variable)
	self.state = state
	self.state:changedState(variable)
end

return statemachine
