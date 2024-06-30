
namespace metatest
{
    void main()
    {
        print("metatest::main()");

        Meta::ExecutingPlugin().Disable();
        print("yielding");
        yield();
    }
}
