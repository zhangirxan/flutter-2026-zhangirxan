#!/usr/bin/env bash
# layer rule: run from the project root before every commit, must print nothing

# http only in core/api and repositories
grep -rl "package:http" lib/ | grep -v -e core/api -e _repository.dart

# no material in models, repositories, core/api
grep -rl "package:flutter/material" lib/ | grep -e _model.dart -e _repository.dart -e core/api

exit 0
