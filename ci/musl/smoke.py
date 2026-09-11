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
import ctypes, json, subprocess, sys
from pathlib import Path
prefix=Path(sys.argv[1])
spec=json.loads(Path('/src/ci/musl/project.json').read_text())
for library in spec['libraries']:
    ctypes.CDLL(str(prefix/'lib'/library))
for command in spec.get('smoke_commands',[]):
    subprocess.run([str(prefix/'bin'/command[0]),*command[1:]],check=True)
loaded=sorted({line.split()[-1] for line in Path('/proc/self/maps').read_text().splitlines() if '/' in line})
assert any(p.startswith(str(prefix)+'/') for p in loaded)
assert not any(p.startswith('/work/') for p in loaded), loaded
print(json.dumps({'loaded_libraries':loaded},indent=2))
print('PASS: relocated prefix in clean offline musl container')
