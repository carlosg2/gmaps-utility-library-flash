# Windows #

  1. Add flex sdk to your environment PATH variable. It's often in "C:\Program Files\Adobe\Flex Builder 3\sdks\3.0.0\bin"
  1. Navigate to the source folder for the library:
cd "C:\Documents and Settings\pamelafox\My Documents\gmaps-utility-library-flash\src\"
  1. Run the command to generate the documentation, changing it to point at the latest available SWC:
asdoc -output ../docs -doc-sources ./ -source-path ./ -external-library-path "C:\Documents and Settings\pamelafox\My Documents\Flex Builder 3\lib\map\_flex\_1\_6.swc"