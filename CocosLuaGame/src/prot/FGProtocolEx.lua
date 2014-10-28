

protDict = {}


function GFProtGet(protId)
    local tempProtDict=protDict[protId]
    if tempProtDict then
        tempProtDict.protId=protId
    end
	return tempProtDict
end


function GFLoadProtToC()
    local protDictBase = FGDeepCopy(protDict)
    CFGLoadProt(protDictBase)
end