from strutils import format, parseInt
from c4.utils import getVersion, join
from strutils import split

# Constants
const
  versionFile = "c4/version.txt"
  pinnedVersion = staticRead(versionFile)

# Package
version = pinnedVersion.split('-')[0]  # don't include number of updates
author = "c0ntribut0r"
description = "Game framework"
license = "MIT"

# Dirs
skipDirs = @["samples"]

# Dependencies
requires "nim >= 0.17.3"

# Tasks
task pinVersion, "Update version file":
  const gitVersion = getVersion()

  if gitVersion != pinnedVersion:
    writeFile(versionFile, gitVersion)
    discard staticExec("git add " & versionFile)
    discard staticExec("git commit --amend --no-edit")
 
    echo("Updated version [$cur] -> [$new]".format([
      "cur", $pinnedVersion,
      "new", $gitVersion,
    ]))
