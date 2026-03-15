.assembly calcul {}
.assembly extern mscorlib {}
.method static void Main()
{
.entrypoint
.maxstack 10
.locals init (int32, int32)
ldc.i4	0
stloc	0
ldc.i4	0
stloc	1
call string class [mscorlib]System.Console::ReadLine()
call int32 int32::Parse(string)
stloc	0
call string class [mscorlib]System.Console::ReadLine()
call int32 int32::Parse(string)
stloc	1
ldloc	0
ldloc	1
add
call void class [mscorlib]System.Console::WriteLine(int32)
ret
}
