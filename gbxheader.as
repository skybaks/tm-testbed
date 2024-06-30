
class HeaderChunkInfo
{
    int ChunkId;
    int ChunkSize;
}

class MapDep
{
    string File;
    string Url;
}

void gbxheader()
{
    string xmlHeader = "";

    auto fid = GetFidFromNod(cast<CGameCtnEditorCommon>(GetApp().Editor).Challenge);
    auto fidfile = cast<CSystemFidFile>(fid);
    if (fidfile !is null)
    {
        print(fidfile.FullFileName);
        IO::File myFile(fidfile.FullFileName);
        myFile.Open(IO::FileMode::Read);
        // ref: pyplanet gbsparser.py
        myFile.SetPos(9);
        int classId = myFile.Read(4).ReadInt32();
        int headerLength = myFile.Read(4).ReadInt32();
        int headerChunkCount = myFile.Read(4).ReadInt32();
        //print("classId:" + tostring(classId) + " headerLength:" + tostring(headerLength) + " headerChunkCount:" + tostring(headerChunkCount));

        HeaderChunkInfo[] chunks = {};

        for (int i = 0; i < headerChunkCount; i++)
        {
            HeaderChunkInfo chunk;
            chunk.ChunkId = myFile.Read(4).ReadInt32();
            chunk.ChunkSize = myFile.Read(4).ReadInt32() & ~0x80000000;
            chunks.InsertLast(chunk);
            //print("chunkId:" + tostring(chunk.ChunkId) + " chunkSize:" + tostring(chunk.ChunkSize));
        }

        for (int i = 0; i < int(chunks.Length); i++)
        {
            MemoryBuffer chunkBuffer = myFile.Read(chunks[i].ChunkSize);
            if (chunks[i].ChunkId == 50606085)
            {
                int chunkSize = chunkBuffer.ReadInt32();
                xmlHeader = chunkBuffer.ReadString(chunkSize);
                print(xmlHeader);
                break;
            }
        }

        myFile.Close();
    }

    MapDep[] deps = {};

    if (xmlHeader != "")
    {
        XML::Document doc;
        doc.LoadString(xmlHeader);
        XML::Node headerNode = doc.Root().FirstChild();
        XML::Node depsHeaderNode = headerNode.Child("deps");
        XML::Node depsNode = depsHeaderNode.FirstChild();
        do
        {
            MapDep newDep;
            newDep.File = depsNode.Attribute("file");
            newDep.Url = depsNode.Attribute("url");
            deps.InsertLast(newDep);
            depsNode = depsNode.NextSibling();
        } while (depsNode);
    }

    for (uint i = 0; i < deps.Length; i++)
    {
        print(deps[i].File);
    }

}