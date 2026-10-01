require "pagy/extras/overflow"

Pagy::DEFAULT[:limit] = 25

# The overflow extra renders a page past the last one empty; a page below 1 is the client's mistake.
ActionDispatch::ExceptionWrapper.rescue_responses["Pagy::VariableError"] = :bad_request
