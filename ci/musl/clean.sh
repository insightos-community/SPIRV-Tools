#!/bin/sh
# Copyright 2026 InsightOS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -eu
exec > /work/logs/clean-install.log 2>&1
mkdir -p /opt/check /opt/runtime
tar -xzf /work/dist/*-musl-x86_64-prefix.tar.gz -C /opt/check
cp /work/runtime/* /opt/runtime/ 2>/dev/null || test -z "$(ls -A /work/runtime)"
export LD_LIBRARY_PATH=/opt/check/prefix/lib:/opt/runtime
python /src/ci/musl/smoke.py /opt/check/prefix
