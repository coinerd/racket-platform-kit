# UX and information design (mobile first)

## Generic Core views

Login/invitation; organization switcher; group membership list; today/upcoming calendar; RSVP detail; messages; private files; notification preferences; role administration. Each screen should work without Football enabled.

## Football-specific views

My children; my team; training RSVP; attendance register; match roster; lineup draft/publish; team group-chat; private team albums; club member administration.

## Navigation behavior

- The landing page shows the next useful action rather than an enterprise dashboard.
- On mobile, default to a short set of primary navigation items; show organization/team context clearly.
- Separate "I plan to attend" from "I actually attended"; do not label silence as rejection.
- Publish lineup is a distinct confirmed action with role-sensitive visibility.
- Photo publishing asks about audience and permission, never defaults to public.
- Avoid noisy unread badges and sensitive notification previews.

## Accessible forms

Semantic HTML labels; meaningful errors near fields; keyboard navigation; focus management; mobile hit areas; contrast checks; clear success/error messages, and never color alone as information. Server-rendered pages must retain basic usability if optional JS enhancement fails.

## Terminology boundaries

Core UI: organization, group, member, event, message, file.
Football UI: club, team, player, guardian, training, match, attendance, lineup.

The UI may rename Core concepts via extension views; Core domain model itself must not import sports vocabulary.
