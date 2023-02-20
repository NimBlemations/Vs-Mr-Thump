package;

#if cpp
typedef EBInt = cpp.Int8; // E = Eight
typedef STBInt = cpp.Int16; // ST = Sixteen
#elseif java
typedef EBInt = java.StdTypes.Int8;
typedef STBInt = java.StdTypes.Int16;
#else
typedef EBInt = Int;
typedef STBInt = Int;
#end