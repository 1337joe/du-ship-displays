package = "du-ship-displays"
version = "scm-0"
source = {
   url = "git://github.com/1337joe/du-ship-displays",
   branch = "main",
}
description = {
   summary = "Info and control screens for Dual Universe ships.",
   homepage = "https://du.w3asel.com/du-ship-displays/",
   license = "MIT",
}
dependencies = {
   "lua >= 5.3",

   -- build/test dependencies
   "luaunit",
   "luacov",
   "du-mocks >= 0.29.1",
   "du-bundler",
}
build = {
   type = "builtin",
   modules = {},
   copy_directories = {},
}
