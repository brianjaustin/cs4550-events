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
* Anyone (anonymous or logged in) may create an event. For this reason,
the event organizer may be chosen from a list of registered users. To
make this more convenient, logged in users default to themselves. _Note_:
this choice will not scale well, so something using Javascript to dynamically
load would be better.
* Even times are not timezone aware, so they will be displayed to everyone
as the time input by the event creator.
* An event may have no participants at all. This is the default state, and
event creators must add each participant individually.

### (Event) Participants
* Do not have to be tied to a user at invitation time, but must register to
RSVP.
* Participants may RSVP without logging in, so long as they have registered at
some point.
