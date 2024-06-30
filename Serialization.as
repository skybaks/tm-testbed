
namespace Serialization
{
    class SettingsSerializer
    {
        private uint8 m_serializerVersion = 1;
        private bool m_allowUpgrade = true;
        private MemoryBuffer m_buffer;
        private Meta::Plugin@ m_plugin;

        SettingsSerializer()
        {
        }

        void SetPlugin(Meta::Plugin@ plugin)
        {
            @m_plugin = plugin;
        }

        string WriteBase64String()
        {
            SerializeToBuffer();
            return "";
            // Sort Settings by VarName ?
        }

        bool ValidateBase64String(const string&in input)
        {
            return false;
            // Read Header
            // Read each Setting
            // CRC?
        }

        private void SerializeToBuffer()
        {
            m_buffer.Resize(0);
            auto settings = m_plugin.GetSettings();
            for (uint settingsIndex = 0; settingsIndex < settings.Length; settingsIndex++)
            {
                auto pluginSetting = settings[settingsIndex];
            }
        }

        // Overall Header
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    0 |    3 | Serializer Version | Integer version for the serializer
        //    0 |    1 | Allow Upgrade Flag | Flag indicating settings can be upgraded
        //    0 |    4 | Settings Count     | Integer number of settings in file
        //    1 |    8 | Plugin Name Hash   | One byte hash of plugin name
        private void WriteOverallHeader(const uint8&in settingsCount, const uint8&in pluginNameHash)
        {
            uint8 byte0 = ((m_serializerVersion & 0x07) << 5) | ((m_allowUpgrade ? 0x01 : 0x00) << 4) | (settingsCount & 0x0f);
            m_buffer.Write(byte0);
            m_buffer.Write(pluginNameHash);
        }
        private void ReadOverallHeader()
        {
            uint8 byte0 = m_buffer.ReadUInt8();
            uint8 serializerVersion = (byte0 >> 5) & 0x07;
            bool allowUpgrade = ((byte0 >> 4) & 0x01) != 0x00;
            uint8 settingsCount = byte0 & 0x0f;
            uint8 pluginNameHash = m_buffer.ReadUInt8();
            warn("TODO: ReadOverallHeader");
        }

        // Setting Header
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    0 |    8 | VarName Hash       | Hash of setting's variable name
        //    1 |    4 | Setting Type       | Type enumeration
        //  1-n |    n | Data               | (See definition of each type)
        void ReadSetting()
        {
            uint8 hashId = m_buffer.ReadUInt8();
            uint8 byte1 = m_buffer.ReadUInt8();
            auto settingType = Meta::PluginSettingType((byte1 >> 4) & 0x0f);
            uint8 byte1_Data = byte1 & 0x0f;

            if (settingType == Meta::PluginSettingType::Bool)
            {
                ReadBool(byte1_Data);
            }
            else if (settingType == Meta::PluginSettingType::Enum
                || settingType == Meta::PluginSettingType::Int8
                || settingType == Meta::PluginSettingType::Int16
                || settingType == Meta::PluginSettingType::Int32)
            {
                ReadInteger(byte1_Data);
            }
        }

        // Bool
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    3 | Spare              | Spare
        //    1 |    1 | Boolean value      | Boolean data
        void WriteBool(Meta::PluginSetting@ setting)
        {
            uint8 byte0 = Hash8(setting.VarName);
            m_buffer.Write(byte0);
            uint8 byte1 = ((uint8(setting.Type) & 0x0f) << 4);

            byte1 |= (setting.ReadBool() ? 0x01 : 0x00);
            m_buffer.Write(byte1);
        }
        void ReadBool(uint8 byte1_Data)
        {
            bool value = (byte1_Data & 0x01) != 0x00;
            warn("TODO: ReadBool");
            error("ReadBool: Do something with the value doofus");
        }

        // Integer/Enum
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Data Bytes Count   | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    1 | Signed/Unsigned    | 1=Signed Data; 0=Unsigned Data
        //    1 |    1 | Spare              | Spare
        //    n |  n*8 | Data               | Integer data
        void WriteInteger(Meta::PluginSetting@ setting)
        {
            uint8 byte0 = Hash8(setting.VarName);
            m_buffer.Write(byte0);
            uint8 byte1 = ((uint8(setting.Type) & 0x0f) << 4);

            int64 value = 0;
            if (setting.Type == Meta::PluginSettingType::Enum)
            {
                value = setting.ReadEnum();
            }
            else if (setting.Type == Meta::PluginSettingType::Int8)
            {
                value = setting.ReadInt8();
            }
            else if (setting.Type == Meta::PluginSettingType::Int16)
            {
                value = setting.ReadInt16();
            }
            else if (setting.Type == Meta::PluginSettingType::Int32)
            {
                value = setting.ReadInt32();
            }
            else
            {
                warn("TODO: handle this");
                error("Unexpected Type in WriteInteger: " + tostring(setting.Type));
            }

            if (value < 0)
            {
                if (value >= int8(0x80))
                {
                    byte1 |= (0x00 << 2);   // 1 byte
                    byte1 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte1);
                    m_buffer.Write(int8(value));
                }
                else if (value >= int16(0x8000))
                {
                    byte1 |= (0x01 << 2);   // 2 byte
                    byte1 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte1);
                    m_buffer.Write(int16(value));
                }
                else if (value >= int(0x80000000))
                {
                    byte1 |= (0x02 << 2);   // 4 byte
                    byte1 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte1);
                    m_buffer.Write(int(value));
                }
                else
                {
                    warn("TODO: handle this");
                    error("Unexpected value occured in WriteInteger: " + tostring(value));
                }
            }
            else
            {
                if (uint64(value) <= uint8(0xff))
                {
                    byte1 |= (0x00 << 2);   // 1 byte
                    byte1 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte1);
                    m_buffer.Write(uint8(value));
                }
                else if (uint64(value) <= uint16(0xffff))
                {
                    byte1 |= (0x01 << 2);   // 2 byte
                    byte1 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte1);
                    m_buffer.Write(uint16(value));
                }
                else if (uint64(value) <= uint(0xffffffff))
                {
                    byte1 |= (0x02 << 2);   // 4 byte
                    byte1 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte1);
                    m_buffer.Write(uint(value));
                }
                else
                {
                    warn("TODO: handle this");
                    error("Unexpected value occured in WriteInteger: " + tostring(value));
                }
            }
        }

        void ReadInteger(uint8 byte1_Data)
        {
            uint8 dataByteEnum = (byte1_Data >> 2) & 0x03;
            bool isSigned = ((byte1_Data >> 1) & 0x01) != 0x00;
            int64 value = 0;
            if (isSigned)
            {
                if (dataByteEnum == 0)
                {
                    value = int8(m_buffer.ReadInt8());
                }
                else if (dataByteEnum == 1)
                {
                    value = int16(m_buffer.ReadInt16());
                }
                else if (dataByteEnum == 2)
                {
                    value = int(m_buffer.ReadInt32());
                }
                else /*if (dataByteEnum == 3)*/
                {
                    value = int64(m_buffer.ReadInt64());
                }
            }
            else
            {
                if (dataByteEnum == 0)
                {
                    value = int8(m_buffer.ReadUInt8());
                }
                else if (dataByteEnum == 1)
                {
                    value = int16(m_buffer.ReadUInt16());
                }
                else if (dataByteEnum == 2)
                {
                    value = int(m_buffer.ReadUInt32());
                }
                else /*if (dataByteEnum == 3)*/
                {
                    value = int64(m_buffer.ReadUInt64());
                }
            }
        }

        // Float
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum   | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum    | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    n |  8*n | Data               | Scaled float data

        // String
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    4 | Data Byte Count 1  | Number of bytes of data. If set to 15, then another byte of count data will follow
        //    2 |    8 | Data Byte Count 2  | [OPTIONAL] If previous field was 15 this is included and data count is sum of both
        // 2/3+ |  n*8 | String Data        | String data of count described

        // Vec2
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum X | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Y | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    4 | Spare              | Spare
        //    n |  n*8 | Data X             | Scaled float data X
        //    n |  n*8 | Data Y             | Scaled float data Y

        // Vec3
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum X | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Y | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Z | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Z  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    n |  n*8 | Data X             | Scaled float data X
        //    n |  n*8 | Data Y             | Scaled float data Y
        //    n |  n*8 | Data Z             | Scaled float data Z

        // Vec4
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum X | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Y | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Z | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Z  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    3 |    2 | Byte Number Enum W | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    3 |    2 | Resolution Enum W  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    3 |    4 | Spare              | Spare
        //    n |  n*8 | Data X             | Scaled float data X
        //    n |  n*8 | Data Y             | Scaled float data Y
        //    n |  n*8 | Data Z             | Scaled float data Z
        //    n |  n*8 | Data W             | Scaled float data W

        private uint8[] m_pearsonHashTable = {198,220,199,236,77,161,247,108,243,229,252,250,126,180,86,146,67,213,15,209,166,130,101,133,211,190,0,98,124,189,121,83,163,105,174,235,148,164,16,56,136,102,240,223,132,4,87,208,10,117,69,64,65,217,253,45,57,210,85,212,13,81,175,233,36,62,154,116,127,170,160,72,203,35,238,194,18,214,110,91,3,197,241,31,43,63,255,107,155,53,206,39,38,112,84,109,179,122,201,70,66,99,73,119,100,123,92,118,29,59,195,51,138,26,147,76,6,219,234,1,142,54,137,182,68,153,104,193,173,222,169,227,215,52,131,183,90,191,141,232,60,225,7,120,24,184,172,96,103,89,205,44,167,32,226,94,88,145,135,156,5,14,41,114,242,2,181,20,23,106,248,143,48,47,254,129,221,249,61,144,140,37,186,157,55,152,78,204,113,30,28,93,50,27,9,168,188,187,19,128,151,159,21,40,12,8,246,34,17,177,22,171,216,202,150,176,231,196,134,251,230,165,244,42,97,95,218,80,239,58,71,115,25,158,11,139,224,192,74,207,228,200,149,185,33,245,125,49,79,178,82,111,162,75,237,46};
        // Pearson Hash
        // Ref: https://en.wikipedia.org/wiki/Pearson_hashing
        private uint8 Hash8(const string&in input)
        {
            uint8 hash = input.Length % 256;
            for (int i = 0; i < input.Length; i++)
            {
                hash = m_pearsonHashTable[hash ^ uint8(input[i])];
            }
            return hash;
        }
        // Pearson Hash
        // Ref: https://en.wikipedia.org/wiki/Pearson_hashing
        private uint16 Hash16(const string&in input)
        {
            uint16 hash = 0;
            for (uint j = 0; j < 2; j++)
            {
                uint8 hash_byte = m_pearsonHashTable[(input[0] + j) % 256];
                for (int i = 0; i < input.Length; i++)
                {
                    hash_byte = m_pearsonHashTable[hash_byte ^ uint8(input[i])];
                }
                hash = ((hash << 8) | hash_byte);
            }
            return hash;
        }
    }
}
