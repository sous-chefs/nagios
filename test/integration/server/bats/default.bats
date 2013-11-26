#!/usr/bin/env bats

@test "nagios should be running" {
  service nagios3 status
}
