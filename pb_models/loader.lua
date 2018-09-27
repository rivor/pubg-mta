local models = {
	["helmet1"] = 1738;
	["helmet2"] = 1745;
	["helmet3"] = 1747;
	["armor1"] = 1749;
	["armor2"] = 1750;
	["armor3"] = 1751;
	["backpack_small"] = 1719;
	["backpack_medium"] = 1725;
	["backpack_large"] = 1736;
	["awm"] = 358;
	["m16a4"] = 356;
	["crowbar"] = 333;
	["machete"] = 339;
	["pan"] = 334;
	["lobby"] = 1782;
};

addEventHandler("onClientResourceStart",root,function()
	for i,v in pairs(models) do
		local tex = engineLoadTXD("models/"..i..".txd", v);
		engineImportTXD(tex, v);
		local mod = engineLoadDFF("models/"..i..".dff", v);
		engineReplaceModel(mod, v);
		if (i == "lobby") then
			local col = engineLoadCOL("models/lobby.col",v);
			engineReplaceCOL(col,v);
		end
	end
end);