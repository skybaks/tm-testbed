
namespace Base64
{
    // ref: https://en.wikipedia.org/wiki/Base64
    const string[] Base64Table = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/"};
    const string Base64Padding = "=";

    string BytesToBase64String(uint8[] bytes)
    {
        string result = "";
        uint bytesIndex = 0;

        while (bytesIndex < bytes.Length)
        {
            uint8 byte1Fragment1 = (bytes[bytesIndex] >> 2) & 0x3f;
            uint8 byte1Fragment2 = (bytes[bytesIndex] & 0x03) << 4;
            uint8 byte2Fragment1 = 0;
            uint8 byte2Fragment2 = 0;
            uint8 byte3Fragment1 = 0;
            uint8 byte3Fragment2 = 0;

            if ((bytesIndex + 1) < bytes.Length)
            {
                byte2Fragment1 = (bytes[bytesIndex + 1] >> 4) & 0x0f;
                byte2Fragment2 = (bytes[bytesIndex + 1] & 0x0f) << 2;
            }

            if ((bytesIndex + 2) < bytes.Length)
            {
                byte3Fragment1 = (bytes[bytesIndex + 2] >> 6) & 0x03;
                byte3Fragment2 = bytes[bytesIndex + 2] & 0x3f;
            }

            result += Base64Table[byte1Fragment1];
            result += Base64Table[byte1Fragment2 | byte2Fragment1];

            if ((bytesIndex + 1) < bytes.Length)
            {
                result += Base64Table[byte2Fragment2 | byte3Fragment1];
            }
            else
            {
                result += Base64Padding;
            }

            if ((bytesIndex + 2) < bytes.Length)
            {
                result += Base64Table[byte3Fragment2];
            }
            else
            {
                result += Base64Padding;
            }

            bytesIndex += 3;
        }

        return result;
    }

    uint8[] Base64StringToBytes(const string&in input)
    {
        uint8[] result = {};
        if (input.Length % 4 != 0) { return result; }

        int charIndex = 0;
        while (charIndex < input.Length)
        {
            int conv1 = Base64Table.Find(input.SubStr(charIndex + 0, 1));
            int conv2 = Base64Table.Find(input.SubStr(charIndex + 1, 1));
            if (conv1 >= 0 && conv2 >= 0)
            {
                result.InsertLast(((conv1 & 0x3f) << 2) | ((conv2 >> 4) & 0x03));
            }

            int conv3 = Base64Table.Find(input.SubStr(charIndex + 2, 1));
            if (conv2 >= 0 && conv3 >= 0)
            {
                result.InsertLast(((conv2 & 0x0f) << 4) | ((conv3 >> 2) & 0x0f));
            }

            int conv4 = Base64Table.Find(input.SubStr(charIndex + 3, 1));
            if (conv3 >= 0 && conv4 >= 0)
            {
                result.InsertLast(((conv3 & 0x03) << 6) | (conv4 & 0x3f));
            }

            charIndex += 4;
        }

        return result;
    }
}