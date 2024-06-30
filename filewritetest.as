
namespace filewritetest
{
    void main()
    {
        print("hello from filewritetest::main()");
        MemoryBuffer mb();
        WriteSomeStuff(mb);
        IO::File outFile(Meta::ExecutingPlugin().SourcePath + "temp.txt", IO::FileMode::Write);
        outFile.Write(mb);
        outFile.Close();
    }

    void WriteSomeStuff(MemoryBuffer@ mb)
    {
        mb.Write("WriteSomeStuff: hello world\n");
        InsideWrite(mb);
        mb.Write("WriteSomeStuff: hello world\n");
    }

    void InsideWrite(MemoryBuffer@ mb)
    {
        mb.Write("InsideWrite: .\n");
        mb.Write("InsideWrite: ...\n");
        mb.Write("InsideWrite: ..\n");
    }
}
