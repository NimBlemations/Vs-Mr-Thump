package;

#if cpp
typedef 8BInt = cpp.Int8;
typedef 16BInt = cpp.Int16;
#elseif java
typedef = 8BInt = java.StdTypes.Int8;
typedef 16BInt = java.StdTypes.Int16;
#else
typedef 8BInt = Int;
typedef 16BInt = Int;
#end