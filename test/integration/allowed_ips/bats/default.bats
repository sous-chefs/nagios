#!/usr/bin/env bats

@test "nagios should be running" {
  ps ax | grep -q nagios.cfg
}

@test "nrpe should be running" {
  ps ax | grep -q nrpe.cfg
}
