from strutils import format
import macros
from ospaths import `/`


proc index*[K, V](iterable: array[K, V], value: V): K {.raises: [ValueError].} =  # TODO: make iterable of type "iterable" or something
  for index, item in iterable.pairs():
    if item == value:
      return index

  raise newException(ValueError, "Cannot find value $value".format([
    "value", value,
  ]))


# proc getAppPath*(): string =
#   result = currentSourcePath()


# TODO: add logger helper - include file name (and possibly line) in log message

template notImplemented*() =
  doAssert(false, "Not implemented")


macro importString*(module, alias: static[string]): untyped =
  result = newNimNode(nnkImportStmt).add(
    newNimNode(nnkInfix).add(newIdentNode("as")).add(newIdentNode(module)).add(newIdentNode(alias))
  )

macro importString*(module: static[string]): untyped =
  result = newNimNode(nnkImportStmt).add(
    newIdentNode(module)
  )

const projectDir {.strdefine.}: string = nil
template importOrFallback*(module: static[string]): untyped =
  when compiles:  # try to import custom module from project root
    importString(projectDir / module)
  else:  # import default implementation
    importString(module)
