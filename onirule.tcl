package provide testcl 0.8
package require log

namespace eval ::testcl {
  variable expectedEvent
  namespace export rule
  namespace export when
  namespace export event
  namespace export run
}

# testcl::rule --
#
# Override of the iRule rule command
#
# Arguments:
# ruleName The name of the rule
# body the body of the rule
#
# Side Effects:
# None.
#
# Results:
# None.
proc ::testcl::rule {ruleName body} {
  log::log debug "rule $ruleName invoked"
  set rc [catch $body result]
  log::log info "rule $ruleName finished, return code: $rc  result: $result"

  if {$rc != 2000} {
    error "Expected return code 2000 from calling when, got $rc"
  } else {
    return "rule $ruleName"
  }
  
}

# testcl::when --
#
# Override of the iRule when command
#
# Arguments:
# event Type of event, for instance HTTP_REQUEST
# body the body of the when command
#
# Side Effects:
# None.
#
# Results:
# None.
proc ::testcl::when {event body} {

  variable expectedEvent

  if {[info exists expectedEvent] && $event eq $expectedEvent} {
    log::log debug "when invoked with expected event '$event'"
    set rc [catch $body result]
    log::log info "when invoked with expected event $event finished, return code: $rc  result: $result"
    
    if {$rc != 1000} {
      error "Expected end state with return code 1000, got $rc"
    }
    
    variable expectedEndState
    
    if {$result ne $expectedEndState} {
      error "Expected end state $expectedEndState, got $result"
    }
    return -code 2000 "when $event"
  } else {
    log::log error "when not invoked due to missing expected event"
    error "when not invoked due to missing expected event"
  }

}

# testcl::event --
#
# Proc to setup the kind of event to expect
#
# Arguments:
# event_type The type of event, either HTTP_REQUEST or HTTP_RESPONSE
#
# Side Effects:
# None.
#
# Results:
# None.

proc ::testcl::event {event_type} {
  variable expectedEvent
  if {$event_type eq "HTTP_REQUEST" || $event_type eq "HTTP_RESPONSE"} {
    set expectedEvent $event_type
  } else {
    log::log error "Usupported event: $event_type. Supported events are HTTP_REQUEST and HTTP_RESPONSE"
    error "Usupported event: $event_type. Supported events are HTTP_REQUEST and HTTP_RESPONSE"
  }
}

# testcl::run --
#
# Run irule
#
# Arguments:
# irule the file containing the irule
# rulename the name of the rule
#
# Side Effects:
# none
#
# Results:
# none
proc ::testcl::run {irule rulename} {
  log::log info "Running irule $irule"
  set rc [catch {source $irule} result]
  testcl::assertNumberEquals 0 $rc
  testcl::assertStringEquals "rule $rulename" $result
}