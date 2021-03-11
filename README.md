# Events

## Design Decisions

### Users
* Email validation happens on the client side primarily, but regex
is used on the backend to enforce this. Non-valid emails are rejected.
* Only one name field is used. Users may put first/last or given/family
name combinations there as they please.

### Events
* May take place in the past. This might be useful if someone wants to
retroactively record that an event took place.
* Event times are not timezone aware, so they will be displayed to everyone
as the time input by the event creator.
* An event may have no participants at all. This is the default state, and
event creators must add each participant individually.
* Event listings are all public (anyone, including anonymous visitors may
list and view them), but edit actions are as described in the spec.

### (Event) Participants
* Do not have to be tied to a user at invitation time, but must register and
be logged in to RSVP. This constraint is validated at the controller level,
not the persistence layer.
