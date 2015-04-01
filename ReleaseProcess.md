# Release Process #

After making changes to a library or adding a new library:
  * Make sure the library roughly follows recommended [coding conventions](http://opensource.adobe.com/wiki/display/flexsdk/Coding+Conventions#CodingConventions-ASDoc).
  * Make sure the library is commented using [ASDoc style comments](http://livedocs.adobe.com/flex/gumbo/html/WSd0ded3821e0d52fe1e63e3d11c2f44bc36-7ff6.html).
  * Re-generate the documentation (See AsDocGeneration). Check that nothing needs to be privatized and that everything public is documented correctly.
  * Commit: new docs, example, source code. Make sure that the mime-types are set correctly for the docs and example (See SVNQuickTips).
  * Update Libraries wiki if you've added a new library.
  * Add any new demos to Flash API demo gallery (Ask Pamela to do this).
  * Post in the forum about the updates.
  * Possibly do a blog post announcing the updates. See BlogPostGuidelines.