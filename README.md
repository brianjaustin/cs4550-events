# Events

## Design Decisions

### Users
* Email validation happens on the client side primarily, but regex
is used on the backend to enforce this. Non-valid emails are rejected.
