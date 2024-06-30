
namespace unicode
{
    void printbyte(uint8 byte)
    {
        string bits = "0b";
        bits += "'";
        bits += (byte & 0x80) != 0 ? "1" : "0";
        bits += (byte & 0x40) != 0 ? "1" : "0";
        bits += (byte & 0x20) != 0 ? "1" : "0";
        bits += (byte & 0x10) != 0 ? "1" : "0";
        bits += "'";
        bits += (byte & 0x08) != 0 ? "1" : "0";
        bits += (byte & 0x04) != 0 ? "1" : "0";
        bits += (byte & 0x02) != 0 ? "1" : "0";
        bits += (byte & 0x01) != 0 ? "1" : "0";
        print(bits);
    }

    // https://www.ibm.com/docs/en/db2/11.5?topic=support-unicode-character-encoding
    string[] tokenize_string(const string&in str)
    {
        string[] tokenized = {};

        int index = 0;
        while (index < str.Length)
        {
            uint8 byte = str[index];
            bool testbit1 = (byte & 0x80) != 0;
            bool testbit2 = (byte & 0x40) != 0;
            bool testbit3 = (byte & 0x20) != 0;
            bool testbit4 = (byte & 0x10) != 0;

            if (!testbit1)
            {
                // normal
                tokenized.InsertLast(str.SubStr(index, 1));
                index += 1;
            }
            else if (testbit1 && !testbit2)
            {
                // inside the character
                error("unexpected");
                break;
            }
            else if (testbit1 && testbit2 && !testbit3)
            {
                // header, 2 bytes
                tokenized.InsertLast(str.SubStr(index, 2));
                index += 2;
            }
            else if (testbit1 && testbit2 && testbit3 && !testbit4)
            {
                // header, 3 bytes
                tokenized.InsertLast(str.SubStr(index, 3));
                index += 3;
            }
            else if (testbit1 && testbit2 && testbit3 && testbit4)
            {
                // header, 4 bytes
                tokenized.InsertLast(str.SubStr(index, 4));
                index += 4;
            }
        }

        return tokenized;
    }
}
